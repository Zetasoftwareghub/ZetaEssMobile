import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';

import '../../../../core/api_constants/approval_manager_apis/approve_apis.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_attendance_regularisation_listing_model.dart';

final approveAttendanceRegularisationRepositoryProvider =
    Provider<ApproveAttendanceRegularisationRepository>((ref) {
      return ApproveAttendanceRegularisationRepository();
    });

class ApproveAttendanceRegularisationRepository {
  final dio = Dio();

  FutureEither<ApproveAttendanceRegularisationListResponse>
  getApproveAttendanceRegularisationList({required UserContext userContext}) {
    return handleApiCall(() async {
      final data = {
        'userid': userContext.esCode,
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,

        'emcode': userContext.empCode,
      };

      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveRegularisationList,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApproveAttendanceRegularisationListResponse.fromJson(
          response.data,
        );
      } else {
        throw Exception('Failed to load ApproveAttendanceRegularisation list');
      }
    });
  }

  FutureEither<String?> approveRejectRegularisation({
    required UserContext userContext,
    required String note,
    required String requestId,
    required String strEmailId,
    required String approveRejectFlag,
  }) {
    return handleApiCall(() async {
      final data = {
        "strAtapfg": approveRejectFlag == 'A' ? '1' : '0',
        "strAtesid": requestId,
        "strEmcode": userContext.empCode,
        "strRemrk": note,
        "strEmalid": strEmailId,
        "strAprtyp": approveRejectFlag == 'A' ? '1' : '2',
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        "url": userContext.baseUrl,
        "baseDirectory": "",
        "eminid": userContext.empEminid,
        "emp_nam": "",
        "emmail": "",
        "emp_mail": "",
      };
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.approveRejectRegularisation,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'].toString();
      } else {
        throw Exception('Failed to approve regularise request');
      }
    });
  }
}

Future getLMAttendanceRegularizationDetails(String id, UserContext user) async {
  try {
    final response = await Dio().post(
      user.baseUrl + ApproveApis.getApproveRegulariseDetails,
      data: {
        "suconn": user.companyConnection,
        "inAtesid": id,
        "emcode": user.empCode,
      },
      options: dioHeader(token: user.jwtToken),
    );

    return response.data['data'];
  } catch (e) {
    return null;
  }
}
