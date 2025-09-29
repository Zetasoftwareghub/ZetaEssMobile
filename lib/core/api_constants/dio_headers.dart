import 'dart:async';

import 'package:dio/dio.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fpdart/fpdart.dart';

import '../error_handling/dio_errors.dart';
import '../error_handling/failure.dart';
import '../error_handling/type_defs.dart';

Options dioHeader({required String? token}) {
  return Options(
    sendTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),

    headers: {
      "authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );
}

FutureEither<T> handleApiCall<T>(Future<T> Function() apiCall) async {
  try {
    final result = await apiCall().timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw DioException.connectionTimeout(
          requestOptions: RequestOptions(path: ''), // fill if needed
          timeout: const Duration(seconds: 60),
        );
      },
    );

    return right(result);
  } on DioException catch (dioError, stack) {
    final errMsg = handleDioException(dioError);
    return left(Failure(errMsg: errMsg));
  } on TimeoutException {
    return left(Failure(errMsg: "Request timed out. Please try again."));
  } catch (e, stack) {
    return left(Failure(errMsg: e.toString()));
  }
}

// FutureEither<T> handleApiCall<T>(Future<T> Function() apiCall) async {
//   try {
//     final result = await apiCall();
//     return right(result);
//   } on DioException catch (dioError, stack) {
//     final errMsg = handleDioException(dioError);
//
//     return left(Failure(errMsg: errMsg));
//   } catch (e, stack) {
//     return left(Failure(errMsg: e.toString()));
//   }
// }
