import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/models/salary_certificate_detail_model.dart';

import '../../../../core/api_constants/approval_manager_apis/approve_apis.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_salary_certificate_listing_model.dart';

final approveSalaryCertificateRepositoryProvider =
    Provider<ApproveSalaryCertificateRepository>((ref) {
      return ApproveSalaryCertificateRepository();
    });

class ApproveSalaryCertificateRepository {
  final dio = Dio();

  FutureEither<ApproveSalaryCertificateListResponse>
  getApproveSalaryCertificateList({required UserContext userContext}) {
    return handleApiCall(() async {
      print(userContext.esCode);
      print('userContext.esCode');
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveSalaryCertificateList,

        data: {
          'userid': userContext.esCode,
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApproveSalaryCertificateListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load ApproveSalaryCertificate list');
      }
    });
  }

  FutureEither<String?> approveRejectSalaryCertificate({
    required UserContext userContext,
    required String note,
    required String certificateId,
    required SalaryCertificateDetailsModel salaryModel,
    required String approveRejectFlag,
  }) {
    return handleApiCall(() async {
      final data = {
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        "id": certificateId,
        "apremcode": userContext.empCode,
        "rqnote": salaryModel.note,
        "apnote": note,
        "uname": salaryModel.employeeName,
        "emcode": salaryModel.employeeId,
        "action": approveRejectFlag,
        "rqdt": salaryModel.submissionDate,
        "mnthyrfrm": salaryModel.fromMonth,
        "mnthyrto": salaryModel.toMonth,
        "purp": salaryModel.purpose,
        "bnk": "",
        "url": "",
        "cocode": 0,
        "baseDirectory": "",
      };
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.approveRejectSalaryCertificate,
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
