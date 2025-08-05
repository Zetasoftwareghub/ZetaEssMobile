// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fpdart/fpdart.dart';
//
// import '../../core/api_constants/auth_apis/auth_api.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/api_errors.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/models/company_model.dart';
import 'package:zeta_ess/models/user_model.dart';

import '../../../core/api_constants/auth_apis/auth_api.dart';
import '../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../core/error_handling/dio_errors.dart';
import '../../../core/error_handling/failure.dart';
import '../../../core/error_handling/type_defs.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  FutureEither activateUrl({required String url}) async {
    try {
      final response = await dio.get('$url${AuthApis.activateUrl}');

      if (response.statusCode == 200 && response.data != null) {
        return right(response.data);
      } else {
        return left(Failure(errMsg: 'Unknown error occurred'));
      }
    } on DioException catch (dioError) {
      final errMsg = handleDioException(dioError);
      return left(Failure(errMsg: 'Invalid Activation Url'));
    } catch (e) {
      return left(Failure(errMsg: 'Invalid Activation Url'));
    }
  }

  FutureEither<UserModel> loginUser({
    required UserContext userContext,
    required String fcmToken,
    required String userName,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final deviceType = Platform.isAndroid ? 'android' : 'ios';

      final payloadData = {
        'userId': userName,
        'password': password.toLowerCase(),
        'deviceId': fcmToken,
        'deviceType': deviceType,
        'suconn': userContext.companyConnection,
      };

      final response = await dio.post(
        '${userContext.baseUrl}${AuthApis.loginInApi}',
        data: payloadData,
      );

      final data = response.data;
      // Defensive: ensure 'data' is a List and has at least one item
      final escodes = data['data'];
      if (escodes is List && escodes.isNotEmpty) {
        final errorCode = escodes[0]['escode']?.toString();

        if (ApiErrors.isError(errorCode, context)) {
          return left(Failure(errMsg: "$errorCode"));
        }
      }

      if (response.statusCode == 200 && data['success'] == true) {
        final user = data['data'] as List<dynamic>;
        return right(UserModel.fromJson(user.first));
      } else {
        showCustomAlertBox(
          context,
          title: 'Error',
          content: 'Unknown server response',
          type: AlertType.error,
        );
        return left(Failure(errMsg: 'Unknown error occurred'));
      }
    } on DioException catch (dioError) {
      final errMsg = handleDioException(dioError);
      return left(Failure(errMsg: errMsg));
    } catch (e) {
      return left(Failure(errMsg: e.toString()));
    }
  }

  FutureEither<UserModel> ssoLogin({
    required UserContext userContext,
    required String email,
    required BuildContext context,
  }) async {
    try {
      final response = await dio.post(
        '${userContext.baseUrl}${AuthApis.ssoLogin}',
        data: {'userMail': email, 'suconn': userContext.companyConnection},
      );

      final data = response.data;

      final escodes = data['data'];
      if (escodes is List && escodes.isNotEmpty) {
        final errorCode = escodes[0]['escode']?.toString();
        if (ApiErrors.isError(errorCode, context)) {
          return left(Failure(errMsg: "API returned error $errorCode"));
        }
      }

      if (response.statusCode == 200 && data != null) {
        final user = data['data'] as List<dynamic>;
        return right(UserModel.fromJson(user.first));
      } else {
        showCustomAlertBox(
          context,
          title: 'Error',
          content: 'Unknown server response',
          type: AlertType.error,
        );
        return left(Failure(errMsg: 'Unknown error occurred'));
      }
    } on DioException catch (dioError) {
      final errMsg = handleDioException(dioError);
      return left(Failure(errMsg: errMsg));
    } catch (e) {
      return left(Failure(errMsg: e.toString()));
    }
  }

  FutureEither<List<CompanyModel>> getCompanies({
    required UserContext userContext,
  }) async {
    try {
      final response = await dio.get(
        userContext.baseUrl + AuthApis.getCompanies,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        final companies =
            data
                .map(
                  (json) => CompanyModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();
        return right(companies);
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

  FutureEither<String?> forgotPassword({
    required UserContext userContext,
    required String userId,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + AuthApis.forgotPassword,
        data: {
          "suconn": userContext.companyConnection,
          "userid": userId,
          "activateurl": userContext.baseUrl,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'].toString();
      } else {
        throw Exception('Failed to load data');
      }
    });
  }
}
