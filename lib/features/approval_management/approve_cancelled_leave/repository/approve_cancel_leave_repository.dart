import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/approval_management/approve_cancelled_leave/models/cancel_leave_model.dart';

import '../../../../core/api_constants/approval_manager_apis/approve_apis.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/cancel_leave_listing.dart';
import '../models/cancel_leave_params.dart';

final approveCancelLeaveRepositoryProvider = Provider<ApproveLeaveRepository>((
  ref,
) {
  return ApproveLeaveRepository();
});

class ApproveLeaveRepository {
  final dio = Dio();

  FutureEither<ApproveCancelLeaveListResponse> getApproveCancelLeaveList({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveCancelLeaveList,
        data: {
          'userid': userContext.esCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApproveCancelLeaveListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load ApproveLeave leaves');
      }
    });
  }

  FutureEither<CancelLeaveModel> getCancelLeaveDetails({
    required UserContext userContext,
    required String? lsslno,
    required String? laslno,
    required String? clslno,
  }) {
    final data = {
      "userid": userContext.esCode,
      "suconn": userContext.companyConnection,
      "emcode": userContext.empCode,
      "lsslno": lsslno,
      "laslno": laslno,
      "clslno": clslno,
    };
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveCancelLeaveDetails,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final raw = response.data['data'] as Map<String, dynamic>;
        return CancelLeaveModel.fromJson(raw);
      } else {
        throw Exception('Failed to load ApproveLeave leaves');
      }
    });
  }

  FutureEither<String?> approveOrRejectLeave({
    required ApproveRejectCancelLeaveParams params,
  }) {
    printFullJson(params.toJson());
    printFullJson('params.toJson()');
    return handleApiCall(() async {
      final response = await dio.post(
        params.userContext.baseUrl +
            (params.strapprflg == "A"
                ? ApproveApis.approveCancelLeave
                : ApproveApis.rejectCancelLeave),
        data: params.toJson(),
        options: dioHeader(token: params.userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'].toString();
      } else {
        throw Exception(
          'Failed to ${params.strapprflg == "A" ? "Approve" : "Reject"} leave',
        );
      }
    });
  }
}
