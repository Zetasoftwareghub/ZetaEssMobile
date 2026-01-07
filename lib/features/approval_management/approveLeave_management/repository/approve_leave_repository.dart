import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';

import '../../../../core/api_constants/approval_manager_apis/approve_apis.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../self_service/leave_management/models/leave_model.dart';
import '../models/approve_leave_listing_model.dart';

final approveLeaveRepositoryProvider = Provider<ApproveLeaveRepository>((ref) {
  return ApproveLeaveRepository();
});

class ApproveLeaveRepository {
  final dio = Dio();

  FutureEither<LeaveApprovalListResponse> getApproveLeaveList({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveLeaveList,
        data: {
          'userid': userContext.esCode,
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return LeaveApprovalListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load ApproveLeave leaves');
      }
    });
  }

  FutureEither<String?> approveLeave({
    required UserContext userContext,
    required String comment,
    required LeaveModel leaveDetails,
  }) {
    return handleApiCall(() async {
      final data = {
        "emcode": userContext.empCode,
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        "id": leaveDetails.leaveId,
        "apremcode": userContext.empCode,
        "levtype": "A",
        "uname": userContext.empName,
        "lvdays": leaveDetails.leaveDays,
        "ltcode": leaveDetails.leaveCode,
        "subdt": leaveDetails.submitted,
        "dtfrm": leaveDetails.leaveFrom,
        "dtto": leaveDetails.leaveTo,
        "reason": comment,
        "note": leaveDetails.note,
        "contno": leaveDetails.emergencyContact,
        "rqall": "1",
        "url": "string",
        "cocode": 0,
        "noOfDays": leaveDetails.leaveDays,
        "baseDirectory": "string",
      };
      //TODO rosenbure test data !
      //{emcode: 7, sucode: 0, suconn: Data Source=192.168.0.44, 1585;Initial Catalog=Rosenbauer;User ID=sa;Password=Cust@Zet@25!;Pooling=True;Max Pool Size=10000;Connect Timeout=60;TrustServerCertificate=True;, id: 1135, apremcode: 7, levtype: A, uname: Christoph  Stiftner, lvdays: 29.0, ltcode: 2, subdt: 10/11/2025, dtfrm: 17/01/2026, dtto: 14/02/2026, reason: , note: Annual leave , contno: , rqall: 1, url: string, cocode: 0, noOfDays: 29.0, baseDirectory: string}
      //{emcode: 7, sucode: 0, suconn: Data Source=192.168.0.44, 1585;Initial Catalog=Rosenbauer;User ID=sa;Password=Cust@Zet@25!;Pooling=True;Max Pool Size=10000;Connect Timeout=60;TrustServerCertificate=True;, id: 1213, apremcode: 7, levtype: A, uname: Christoph  Stiftner, lvdays: 14.0, ltcode: 2, subdt: 18/12/2025, dtfrm: 26/12/2025, dtto: 08/01/2026, reason: , note: my father passed away , contno: , rqall: 1, url: string, cocode: 0, noOfDays: 14.0, baseDirectory: string}
      print(data);
      print("data");
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.approveLeave,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      print(response.statusCode);
      print(response.data);
      print("response.data");
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'].toString();
      } else {
        throw Exception('Failed to Leave request');
      }
    });
  }

  FutureEither<String?> rejectLeave({
    required UserContext userContext,
    required LeaveModel leaveDetails,
    required String comment,
  }) {
    return handleApiCall(() async {
      final data = {
        "rejdate": formatDate(DateTime.now()),
        "emcode": userContext.empCode,
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        "id": leaveDetails.leaveId,
        "apremcode": userContext.empCode,
        "levtype": "A",
        "uname": userContext.empName,
        "lvdays": leaveDetails.leaveDays,
        "ltcode": leaveDetails.leaveCode,
        "subdt": leaveDetails.submitted,
        "dtfrm": leaveDetails.leaveFrom,
        "dtto": leaveDetails.leaveTo,
        "reason": comment,
        "note": leaveDetails.note,
        "contno": leaveDetails.emergencyContact,
        "rqall": "1",
        "url": "string",
        "cocode": 0,
        "noOfDays": leaveDetails.leaveDays,
        "baseDirectory": "string",
      };
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.rejectLeave,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'].toString();
      } else {
        throw Exception('Failed to ApproveLieuDay request');
      }
    });
  }
}
