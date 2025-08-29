import 'package:dio/dio.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fpdart/fpdart.dart';

import '../error_handling/dio_errors.dart';
import '../error_handling/failure.dart';
import '../error_handling/type_defs.dart';

Options dioHeader({required String? token}) {
  return Options(
    headers: {
      "authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );
}
//
// FutureEither<T> handleApiCall<T>(Future<T> Function() apiCall) async {
//   try {
//     final result = await apiCall();
//     return right(result);
//   } on DioException catch (dioError) {
//     final errMsg = handleDioException(dioError);
//     return left(Failure(errMsg: errMsg));
//   } catch (e) {
//     return left(Failure(errMsg: e.toString()));
//   }
// }

FutureEither<T> handleApiCall<T>(Future<T> Function() apiCall) async {
  try {
    final result = await apiCall();
    return right(result);
  } on DioException catch (dioError, stack) {
    final errMsg = handleDioException(dioError);

    // Report DioException to Crashlytics
    // await FirebaseCrashlytics.instance.recordError(
    //   dioError,
    //   stack,
    //   reason: "DioException in handleApiCall",
    //   information: [errMsg],
    // );

    return left(Failure(errMsg: errMsg));
  } catch (e, stack) {
    // Report any other exception to Crashlytics
    // await FirebaseCrashlytics.instance.recordError(
    //   e,
    //   stack,
    //   reason: "Unexpected error in handleApiCall",
    // );

    return left(Failure(errMsg: e.toString()));
  }
}
