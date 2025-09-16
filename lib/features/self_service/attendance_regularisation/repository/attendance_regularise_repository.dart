import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/api_constants/self_service_apis/regularise_apis.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/features/self_service/attendance_regularisation/models/submit_regularise_model.dart';

import '../../../../core/error_handling/failure.dart';
import '../../../../core/error_handling/type_defs.dart';
import '../models/regularise_calendar_models.dart';

//TODO remove this global to make it private to this file
Future getCalendarData({
  required String dateFrom,
  required String dateTo,
  required UserContext userContext,
}) async {
  try {
    final response = await Dio().post(
      "${userContext.baseUrl}/api/Leave/BindMyCalendar_MobileApp/getCalendarData",
      data: {
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        "strEmcodes": userContext.empEminid,
        "dtStart": dateFrom.toString(),
        "dtEnd": dateTo.toString(),
      },
      options: dioHeader(token: userContext.jwtToken),
    );
    final responseJson = response.data['data'];

    return responseJson;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

final attendanceRegulariseRepositoryProvider =
    Provider<AttendanceRegulariseRepository>((ref) {
      return AttendanceRegulariseRepository();
    });

class AttendanceRegulariseRepository {
  final dio = Dio();

  FutureEither<String?> submitRegulariseLeave({
    required SubmitRegulariseModel submitRequest,
    required UserContext userContext,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + RegulariseApis.submitRegularisation,
        data: submitRequest.toJson(
          emalid: userContext.empEminid,
          emcode: userContext.empCode,
          empname: userContext.empName,
          suconn: userContext.companyConnection ?? '',
          url: userContext.baseUrl,
          sucode: userContext.companyCode,
        ),
        options: dioHeader(token: userContext.jwtToken),
      );
      return response.data['data'];
    });
  }

  FutureEither<RegulariseCalenderDetailResponse> getCalendarDetails({
    required UserContext userContext,
    required String regulariseDate,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + RegulariseApis.getCalendarDetails,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          "strEmalid": userContext.empEminid,
          "dtAttDate": regulariseDate,
          "strAtStat": "E",
          "userid": int.parse(userContext.esCode),
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      print(response);
      //TODO check the response and parse throug from JSON accordingly
      print(response.data['data'][0]);
      final regulariseData = response.data['data'] as Map<String, dynamic>;
      return RegulariseCalenderDetailResponse.fromJson(regulariseData);
    });
  }

  //TODO this is not given in UI still pending
  FutureEither<List<Map<String, dynamic>>> getCalendarData({
    required String dateFrom,
    required String dateTo,
    required UserContext userContext,
  }) async {
    try {
      print(userContext.empCode);
      print(dateFrom);
      print('dateFrom');
      print(dateTo);
      final response = await Dio().post(
        userContext.baseUrl + RegulariseApis.getCalendarData,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          "strEmcodes": userContext.empCode,
          "dtStart": dateFrom,
          "dtEnd": dateTo,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      final responseJson = response.data['data'] as List<dynamic>;

      return right(responseJson.cast<Map<String, dynamic>>());
    } catch (e) {
      print("Error in getCalendarData: $e");
      return left(Failure(errMsg: e.toString()));
    }
  }
}
