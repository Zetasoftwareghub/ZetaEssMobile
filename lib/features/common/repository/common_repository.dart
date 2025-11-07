import 'dart:core';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../core/api_constants/common_apis/common_apis.dart';
import '../../../core/api_constants/dio_headers.dart';
import '../../../core/error_handling/type_defs.dart';
import '../../../core/providers/userContext_provider.dart';
import '../models/announcement_model.dart';
import '../models/download_model.dart';
import '../models/holiday_calendar_models.dart';
import '../models/notification_model.dart';
import '../models/suggestion_model.dart';

final commonRepositoryProvider = Provider<CommonRepository>((ref) {
  return CommonRepository();
});

class CommonRepository {
  final dio = Dio();

  FutureEither<String> saveSuggestion({
    required SuggestionModel suggestion,
    required UserContext userContext,
  }) {
    final baseUrl = userContext.baseUrl + CommonApis.saveSuggestion;
    printFullJson(suggestion.toJson());
    printFullJson('suggestion.toJson()');
    return handleApiCall(() async {
      final response = await dio.post(
        baseUrl,
        data: suggestion.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  FutureEither<List<DocumentModel>> getDownloads({
    required UserContext userContext,
  }) {
    final baseUrl = userContext.baseUrl + CommonApis.getDownloads;

    return handleApiCall(() async {
      final response = await dio.post(
        baseUrl,
        data: userContext.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => DocumentModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  FutureEither<List<HolidayRegion>> getHolidayCalendarRegion({
    required UserContext userContext,
  }) {
    final baseUrl = userContext.baseUrl + CommonApis.getHolidayCalendarRegion;
    return handleApiCall(() async {
      final response = await dio.post(
        baseUrl,
        data: userContext.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => HolidayRegion.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  FutureEither<List<HolidayListModel>> getHolidayCalendar({
    required UserContext userContext,
    required String year,
    required String region,
  }) {
    final baseUrl = userContext.baseUrl + CommonApis.getHolidayCalendar;

    return handleApiCall(() async {
      final response = await dio.post(
        baseUrl,
        data: {
          'year': year,
          'code': region,
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,

          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => HolidayListModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  FutureEither<List<DocumentModel>> getPaySlips({
    required UserContext userContext,
    required String year,
  }) {
    final baseUrl = userContext.baseUrl + CommonApis.getPaySlips;

    return handleApiCall(() async {
      final response = await dio.post(
        baseUrl,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          "emcode": userContext.empCode,
          "year": year,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => DocumentModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  FutureEither<String?> paySlipDownloadUrl({
    required UserContext userContext,
    required String year,
    required String monthName,
  }) {
    final baseUrl = userContext.baseUrl + CommonApis.paySlipDownloadUrl;
    final data = {
      'sucode': userContext.companyCode,
      'suconn': userContext.companyConnection,
      "emcode": userContext.empCode,
      "year": int.parse(year),
      "month": int.parse(monthName),
      "baseUrl": userContext.userBaseUrl,
    };
    print(data);
    print('payslip');

    return handleApiCall(() async {
      final response = await dio.post(
        baseUrl,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      print(response);
      print("payresponse");
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  FutureEither<List<AnnouncementModel>> getAnnouncements({
    required UserContext userContext,
  }) {
    final baseUrl = userContext.baseUrl + CommonApis.getAnnouncements;
    final suconn = Uri.encodeComponent(userContext.companyConnection ?? '');
    final fullUrl = "$baseUrl?suconn=$suconn";

    return handleApiCall(() async {
      final response = await dio.post(
        fullUrl,
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'][0];
        return data.map((e) => AnnouncementModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  FutureEither<List<NotificationModel>> getPendingRequestNotification({
    required UserContext userContext,
  }) {
    final baseUrl = userContext.baseUrl + CommonApis.getPendingRequest;
    print(userContext.toJson());
    return handleApiCall(() async {
      final response = await dio.post(
        baseUrl,
        data: userContext.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'][0];
        return data
            .map((e) => NotificationModel.fromJsonPendingApi(e))
            .toList();
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  FutureEither<List<NotificationModel>> getPendingApprovalsNotification({
    required UserContext userContext,
  }) {
    final baseUrl = userContext.baseUrl + CommonApis.getPendingApprovals;

    return handleApiCall(() async {
      final response = await dio.post(
        baseUrl,
        data: userContext.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'][0];
        return data
            .map((e) => NotificationModel.fromJsonApprovalApi(e))
            .toList();
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  FutureEither<String?> changePassword({
    required UserContext userContext,
    required String oldPassword,
    required String newPassword,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + CommonApis.changePassword,
        data: {
          "userid": userContext.esCode,
          "pwd": newPassword,
          "oldpwd": oldPassword,
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw 'Something went wrong';
      }
    });
  }
}
