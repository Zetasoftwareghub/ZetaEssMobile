import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

String handleDioException(DioException dioError) {
  final response = dioError.response;
  final statusCode = response?.statusCode;

  switch (dioError.type) {
    case DioExceptionType.connectionTimeout:
      return "connectionTimedOut".tr();
    case DioExceptionType.sendTimeout:
      return "sendTimeout".tr();
    case DioExceptionType.receiveTimeout:
      return "receiveTimeout".tr();
    case DioExceptionType.badResponse:
      if (response?.data.isEmpty) {
        return 'noDataReceived'.tr();
      } else if (statusCode == 401) {
        return response?.data['message']?.toString() ?? "unauthorized".tr();
      } else if (statusCode == 403) {
        return "forbidden".tr();
      } else if (statusCode == 404) {
        return "notFound".tr();
      } else if (statusCode == 500) {
        return "No data found".tr();
      } else {
        return response?.data['message']?.toString() ??
            "genericError".tr(args: [statusCode?.toString() ?? 'Unknown']);
      }
    case DioExceptionType.cancel:
      return "requestCancelled".tr();
    case DioExceptionType.badCertificate:
      return "badCertificate".tr();
    case DioExceptionType.connectionError:
      return "connectionError".tr();
    case DioExceptionType.unknown:
      return dioError.message ?? "unknownError".tr();
  }
}
