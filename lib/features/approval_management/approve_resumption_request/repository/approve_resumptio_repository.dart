import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';

import '../../../../core/api_constants/approval_manager_apis/approve_apis.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_resumption_listing_model.dart';

final approveResumptionRepositoryProvider =
    Provider<ApproveResumptionRepository>((ref) {
      return ApproveResumptionRepository();
    });

class ApproveResumptionRepository {
  final dio = Dio();

  FutureEither<ApproveResumptionListResponse> getApproveResumptionList({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveResumptionList,
        data: {
          'userid': userContext.esCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApproveResumptionListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load ApproveResumption leaves');
      }
    });
  }

  FutureEither<String?> approveRejectResumption({
    required UserContext userContext,
    required String note,
    required String requestId,
    required String approveRejectFlag,
  }) {
    return handleApiCall(() async {
      final data = {
        "strapprflg": approveRejectFlag,
        "reslno": requestId,
        "strEmcode": userContext.empCode,
        "username": userContext.empName,
        "strNote": note,
        "suconn": userContext.companyConnection,
      };

      final response = await dio.post(
        userContext.baseUrl + ApproveApis.approveRejectResumption,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to ApproveLieuDay request');
      }
    });
  }
}
