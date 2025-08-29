import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';
import 'package:zeta_ess/features/self_service/salary_advance/models/salary_advance_details.dart';

import '../../../../core/api_constants/approval_manager_apis/approve_apis.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_salary_advance_listing_model.dart';

final approveSalaryAdvanceRepositoryProvider =
    Provider<ApproveSalaryAdvanceRepository>((ref) {
      return ApproveSalaryAdvanceRepository();
    });

class ApproveSalaryAdvanceRepository {
  final dio = Dio();

  FutureEither<ApproveSalaryAdvanceListResponse> getApproveSalaryAdvanceList({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveSalaryAdvanceList,
        data: {
          'userid': userContext.esCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApproveSalaryAdvanceListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load ApproveSalaryAdvance list');
      }
    });
  }

  FutureEither<String?> approveSalaryAdvance({
    required UserContext userContext,
    required SalaryAdvanceDetailsModel salaryDetails,
    required String approveAmount,
    required String comment,

    required String requestId,
  }) {
    return handleApiCall(() async {
      final url = userContext.baseUrl + ApproveApis.approveSalaryAdvance;
      final data = {
        "suconn": userContext.companyConnection,
        "id": requestId,
        "apremcode": userContext.empCode,
        "emcode": salaryDetails.emcode,
        "uname": salaryDetails.name,
        "rqnote": salaryDetails.note,
        "apnote": comment,
        "mnth": salaryDetails.month,
        "year": salaryDetails.year,
        "crcode": "INR",
        "conrate": 1.00,
        "apramnt": approveAmount,
        "rqdt": salaryDetails.subDate,
        "rqamt": salaryDetails.amount,
        "url": "string",
        "cocode": 0,
        "baseDirectory": "string",
      };

      final response = await dio.post(
        url,
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

  FutureEither<String?> rejectSalaryAdvance({
    required UserContext userContext,
    required SalaryAdvanceDetailsModel salaryDetails,
    required String approveAmount,
    required String comment,

    required String requestId,
  }) {
    return handleApiCall(() async {
      final url = userContext.baseUrl + ApproveApis.rejectSalaryAdvance;
      final data = {
        "suconn": userContext.companyConnection,
        "id": requestId,
        "apremcode": userContext.empCode,
        "emcode": salaryDetails.emcode,
        "uname": salaryDetails.name,
        "rqnote": salaryDetails.note,
        "apnote": comment,
        "mnthyr": "",
        "mnth": salaryDetails.month,
        "year": salaryDetails.year,
        "crcode": "INR",
        "conrate": 1.00,
        "apramnt": approveAmount,
        "rqdt": salaryDetails.subDate,
        "rqamt": salaryDetails.amount,
        "url": "string",
        "cocode": 0,
        "baseDirectory": "string",
      };
      final response = await dio.post(
        url,
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
