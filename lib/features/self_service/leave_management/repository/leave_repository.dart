import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zeta_ess/core/api_constants/self_service_apis/leave_managment_apis.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/api_constants/dio_headers.dart';
import '../../../../core/error_handling/dio_errors.dart';
import '../../../../core/error_handling/failure.dart';
import '../../../../core/error_handling/type_defs.dart';
import '../../../../core/utils/date_utils.dart';
import '../models/leaveSubmission_model.dart';
import '../models/leave_model.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository();
});

class LeaveRepository {
  final dio = Dio();

  Future getEditLeaveDetails({
    required UserContext userContext,
    required int leaveId,
  }) async {
    try {
      final response = await dio.post(
        userContext.baseUrl + LeaveManagementApis.getEditLeaveDetails,
        data: {
          "escode": userContext.esCode,
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,

          "id": leaveId,
          "emcode": userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      return response.data['data'];
    } catch (e) {
      print(e.toString());
      print('e.toString()');
      return [];
    }
  }

  FutureEither<LeaveModel> getApprovalLeaveDetails({
    required UserContext userContext,
    required String leaveId,
  }) async {
    try {
      final data = {
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        'emcode': userContext.empCode,
        'id': leaveId,
      };
      print(data);
      print('detail s');
      final response = await dio.post(
        userContext.baseUrl + LeaveManagementApis.getApprovalLeaveDetails,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final leaveData = response.data['data'][0];
        return right(LeaveModel.fromLeaveDetailApi(leaveData));
      } else {
        return left(Failure(errMsg: 'Unknown error occurred'));
      }
    } on DioException catch (dioError) {
      final errMsg = handleDioException(dioError);
      return left(Failure(errMsg: errMsg));
    } catch (e) {
      return left(Failure(errMsg: e.toString()));
    }
  }

  FutureEither<LeaveEditResponse> getSelfLeaveDetails({
    required UserContext userContext,
    required String leaveId,
  }) async {
    try {
      final data = {
        'id': int.parse(leaveId),
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        'escode': int.parse(userContext.esCode),
        'emcode': int.parse(userContext.empCode),
      };
      print(data);
      print('edit leave');
      final response = await dio.post(
        userContext.baseUrl + LeaveManagementApis.getSelfLeaveDetails,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final leaveData = response.data['data'];
        return right(
          LeaveEditResponse.fromEditApi(leaveData),
        ); //TODO not the config values but others
      } else {
        return left(Failure(errMsg: 'Unknown error occurred'));
      }
    } on DioException catch (dioError) {
      final errMsg = handleDioException(dioError);
      return left(Failure(errMsg: errMsg));
    } catch (e) {
      return left(Failure(errMsg: e.toString()));
    }
  }

  FutureEither<SubmittedLeaveResponse> getSubmittedLeaves({
    required UserContext userContext,
  }) async {
    try {
      final response = await dio.post(
        userContext.baseUrl + LeaveManagementApis.getSubmittedLeaves,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'escode': userContext.esCode,
          'dtleave': formatDate(DateTime.now()),
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return right(SubmittedLeaveResponse.fromJson(response.data));
      } else {
        return left(Failure(errMsg: 'Unknown error occurred'));
      }
    } on DioException catch (dioError) {
      final errMsg = handleDioException(dioError);
      return left(Failure(errMsg: errMsg));
    } catch (e) {
      return left(Failure(errMsg: e.toString()));
    }
  }

  FutureEither<List<LeaveModel>> getApprovedLeaves({
    required UserContext userContext,
  }) {
    return _fetchLeaves(
      endpoint: LeaveManagementApis.getApprovedLeaves,
      userContext: userContext,
    );
  }

  FutureEither<List<LeaveModel>> getRejectedLeaves({
    required UserContext userContext,
  }) {
    return _fetchLeaves(
      endpoint: LeaveManagementApis.getRejectedLeaves,
      userContext: userContext,
    );
  }

  FutureEither<List<LeaveModel>> getCancelledLeaves({
    required UserContext userContext,
  }) {
    return _fetchLeaves(
      endpoint: LeaveManagementApis.getCancelledLeaves,
      userContext: userContext,
    );
  }

  FutureEither<List<LeaveModel>> _fetchLeaves({
    required String endpoint,
    required UserContext userContext,
  }) async {
    return handleApiCall(() async {
      final data = {
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        'emcode': userContext.empCode,
        'escode': userContext.esCode,
        'dtleave': formatDate(DateTime.now()),
      };
      final response = await dio.post(
        userContext.baseUrl + endpoint,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final rawData = response.data['data'];

        if (rawData is List && rawData.isNotEmpty) {
          final data = rawData[0] as List;
          final leaves = data.map((e) => LeaveModel.fromJson(e)).toList();
          return leaves;
        } else {
          return <LeaveModel>[];
        }
      } else {
        throw Exception('Api call failed with status: ${response.statusCode}');
      }
    });
  }

  FutureEither<List<LeaveTypeModel>> getLeaveTypes({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LeaveManagementApis.getLeaveTypes,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'escode': userContext.esCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final rawData = response.data['data'];
        if (rawData is Map && rawData['subLst'] != null) {
          final data = rawData['subLst'] as List;
          final leaveTypes =
              data.map((e) => LeaveTypeModel.fromJson(e)).toList();
          return leaveTypes;
        } else {
          return <LeaveTypeModel>[];
        }
      } else {
        throw Exception('Api call failed with status: ${response.statusCode}');
      }
    });
  }

  FutureEither<String> getTotalLeaveDays({
    required UserContext userContext,
    required String dateFrom,
    required String dateTo,
    required String leaveCode,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LeaveManagementApis.getTotalLeaveDays,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'dtfrm': dateFrom,
          'dtto': dateTo,
          'leavcode': leaveCode,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final rawData = response.data['data'];
        if (rawData is Map && rawData['subLst'] != null) {
          final data = rawData['subLst'] as List;
          final leaveDays = data.first['lLsrndy'].toString();
          return leaveDays;
        } else {
          return '';
        }
      } else {
        throw Exception('Api call failed with status: ${response.statusCode}');
      }
    });
  }

  FutureEither<bool?> submitLeaveFirstApi({
    required String leaveCode,
    required String fromDate,
    required String toDate,
    required UserContext userContext,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LeaveManagementApis.submitLeaveFirstApi,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection ?? "",
          "emcode": userContext.empCode,
          "ltcode": leaveCode,
          "strdat": convertDateToIso(fromDate),
          "enddat": convertDateToIso(toDate),
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      return response.data['success'] == true;
    });
  }

  FutureEither<String?> submitLeave(
    LeaveSubmissionRequest request,
    UserContext userContext,
  ) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LeaveManagementApis.submitLeave,
        data: request.toJson(
          userContext.companyConnection ?? "",
          userContext.companyCode ?? "",
          userContext.empCode,
          userContext.esCode,
          userContext.esCode,
          userContext.baseUrl,
        ),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'].toString();
      } else {
        return 'Cannot submit leave';
      }
    });
  }

  FutureEither<bool> deleteLeave({
    required UserContext userContext,
    required int leaveId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LeaveManagementApis.deleteLeave,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'id': leaveId,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      print(response.data['data']);
      print('response.data');
      return response.data['data'].toString().toLowerCase() == 'true';
    });
  }

  FutureEither<String> cancelLeave({
    required UserContext userContext,
    required String lsslno,
    required String dateFrom,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LeaveManagementApis.cancelLeave,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          "emcode": userContext.empCode,
          "lsslno": lsslno,
          "dpFrom": dateFrom,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'].toString();
      } else {
        return 'Cannot cancel leave';
      }
    });
  }
}
