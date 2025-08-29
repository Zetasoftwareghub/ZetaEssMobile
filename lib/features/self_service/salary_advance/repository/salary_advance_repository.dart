import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';

import '../../../../core/api_constants/dio_headers.dart';
import '../../../../core/api_constants/self_service_apis/salary_advance_apis.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/salaryAdvance_listing_model.dart';
import '../models/salary_advance_details.dart';
import '../models/submit_salary_advance.dart';

final salaryAdvanceRepositoryProvider = Provider<SalaryAdvanceRepository>((
  ref,
) {
  return SalaryAdvanceRepository();
});

class SalaryAdvanceRepository {
  final dio = Dio();

  FutureEither<String?> submitSalaryAdvance({
    required SubmitSalaryAdvanceModel submitModel,
    required UserContext userContext,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + SalaryAdvanceApis.submitSalaryAdvance,
        data: submitModel.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as String?;
      } else {
        return 'Failed to submit lieu day';
      }
    });
  }

  FutureEither<SalaryAdvanceListResponse> getSalaryAdvanceList({
    required UserContext userContext,
  }) async {
    final data = {
      'suconn': userContext.companyConnection,
      'emcode': userContext.empCode,
      'userid': userContext.esCode,
      'micode': 84,
    };
    print(data);
    print('tabbsbs');
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + SalaryAdvanceApis.getSalaryAdvanceList,

        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return SalaryAdvanceListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lieu days');
      }
    });
  }

  FutureEither<SalaryAdvanceDetailsModel> getSalaryAdvanceDetails({
    required UserContext userContext,
    required String salaryAdvanceId,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + SalaryAdvanceApis.getSalaryAdvanceDetails,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'id': salaryAdvanceId,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return SalaryAdvanceDetailsModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load lieu days');
      }
    });
  }

  FutureEither<bool> deleteSalaryAdvance({
    required UserContext userContext,
    required String? salaryAdvanceId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + SalaryAdvanceApis.deleteSalaryAdvance,
        data: {
          'suconn': userContext.companyConnection,
          'id': int.parse(salaryAdvanceId ?? '0'),
          'username': userContext.empName,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      return response.data['data'].toString().toLowerCase() == 'true';
    });
  }
}
