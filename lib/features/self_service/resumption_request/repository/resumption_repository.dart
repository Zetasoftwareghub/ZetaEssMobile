import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/api_constants/self_service_apis/resumption_apis.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';
import 'package:zeta_ess/features/self_service/resumption_request/models/resumption_details_model.dart';
import 'package:zeta_ess/features/self_service/resumption_request/models/resumption_leave_model.dart';
import 'package:zeta_ess/features/self_service/resumption_request/models/resumption_listing_model.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/submit_resumption_model.dart';

final resumptionRepositoryProvider = Provider<ResumptionRepository>((ref) {
  return ResumptionRepository();
});

class ResumptionRepository {
  final dio = Dio();

  FutureEither<List<ResumptionLeaveModel>> getResumptionLeaves({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      print(userContext.empCode);
      final response = await dio.post(
        userContext.baseUrl + ResumptionApis.getResumptionLeavesDropDown,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': int.parse(userContext.empCode),
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['data']['subLst'] as List? ?? [])
            .map((e) => ResumptionLeaveModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load resumption leaves');
      }
    });
  }

  FutureEither<String?> deleteResumption({
    required UserContext userContext,
    required int? resumptionId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ResumptionApis.deleteResumptionLeaves,
        data: {
          'suconn': userContext.companyConnection,
          'id': resumptionId,
          'mi_code': '0',
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      return response.data['data'];
    });
  }

  FutureEither<ResumptionDetailModel> getResumptionDetails({
    required UserContext userContext,
    required int resumptionId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ResumptionApis.getResumptionLeaveDetails,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'reslno': resumptionId,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ResumptionDetailModel.fromJson(
          response.data['data']['subLst'][0],
        );
      } else {
        throw Exception('Failed to load resumption leaves');
      }
    });
  }

  FutureEither<ResumptionListResponse> getResumptionList({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ResumptionApis.getResumptionList,
        data: {
          'micode': 112,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'escode': userContext.esCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ResumptionListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load resumption leaves');
      }
    });
  }

  FutureEither<String?> submitResumptionLeave({
    required UserContext userContext,
    required SubmitResumptionModel resumptionModel,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ResumptionApis.submitResumptionLeave,
        data: resumptionModel.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as String?;
      } else {
        throw Exception('Failed to submit resumption leave');
      }
    });
  }
}
