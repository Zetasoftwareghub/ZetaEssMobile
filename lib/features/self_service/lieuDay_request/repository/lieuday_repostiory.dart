import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api_constants/dio_headers.dart';
import '../../../../core/api_constants/self_service_apis/lieuDay_apis.dart';
import '../../../../core/error_handling/type_defs.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/lieuDay_details_model.dart';
import '../models/lieuDay_listing_model.dart';
import '../models/submit_lieuDay_model.dart';

final lieuDayRepositoryProvider = Provider<LieuDayRepository>(
  (ref) => LieuDayRepository(),
);

class LieuDayRepository {
  final dio = Dio();

  FutureEither<String?> submitLieuDay({
    required SubmitLieuDayRequest submitModel,
    required UserContext userContext,
  }) async {
    return handleApiCall(() async {
      final prettyJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(submitModel.toJson());
      debugPrint(prettyJson, wrapWidth: 1024);

      final response = await dio.post(
        userContext.baseUrl + LieuDayApis.submitLieuDay,
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

  FutureEither<LieuDayListResponse> getLieuDayList({
    required UserContext userContext,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LieuDayApis.getLieuDays,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'userid': userContext.esCode,
          'micode': 84,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return LieuDayListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lieu days');
      }
    });
  }

  FutureEither<LieuDayDetailsModel> getLieuDayDetails({
    required UserContext userContext,
    required String lieuDayId,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LieuDayApis.getLieuDayDetails,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'rqldcode': lieuDayId,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return LieuDayDetailsModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load lieu days');
      }
    });
  }

  FutureEither<bool> deleteLieuDay({
    required UserContext userContext,
    required int lieuDayId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LieuDayApis.deleteLieuDay,
        data: {
          'suconn': userContext.companyConnection,
          'id': lieuDayId,
          'mi_code': '0',
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      return response.data['data'].toString().toLowerCase() ==
          'deleted successfully';
    });
  }
}
