import 'package:dio/dio.dart';
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

FutureEither<T> handleApiCall<T>(Future<T> Function() apiCall) async {
  try {
    final result = await apiCall();
    return right(result);
  } on DioException catch (dioError) {
    final errMsg = handleDioException(dioError);
    return left(Failure(errMsg: errMsg));
  } catch (e) {
    return left(Failure(errMsg: e.toString()));
  }
}
