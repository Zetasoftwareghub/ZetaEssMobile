import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';

import '../../../../core/api_constants/dio_headers.dart';
import '../../../../core/api_constants/self_service_apis/salary_certificate_apis.dart';
import '../../../../core/error_handling/dio_errors.dart';
import '../../../../core/error_handling/failure.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/salary_certificate_detail_model.dart';
import '../models/salary_certificate_listing_model.dart';
import '../models/submit_salary_certificate_model.dart';

final salaryCertificateRepositoryProvider =
    Provider<SalaryCertificateRepository>((ref) {
      return SalaryCertificateRepository();
    });

class SalaryCertificateRepository {
  final dio = Dio();

  FutureEither<SalaryCertificateListResponse> getSalaryCertificateList({
    required UserContext userContext,
  }) async {
    try {
      final response = await dio.post(
        userContext.baseUrl + SalaryCertificateApis.getSalaryCertificateList,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'userid': userContext.esCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return right(SalaryCertificateListResponse.fromJson(response.data));
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

  FutureEither<String> submitSalaryCertificate({
    required UserContext userContext,
    required SubmitSalaryCertificateModel submitModel,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + SalaryCertificateApis.submitSalaryCertificate,
        data: submitModel.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );

      return response.data['data'].toString();
    });
  }

  FutureEither<bool> deleteSalaryCertificate({
    required UserContext userContext,
    required int salaryCertificateId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + SalaryCertificateApis.deleteSalaryCertificate,
        data: {
          'suconn': userContext.companyConnection,
          'id': salaryCertificateId,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      return response.data['data'].toString().toLowerCase() == 'true';
    });
  }

  FutureEither<SalaryCertificateDetailsModel> getSalaryCertificateDetails({
    required UserContext userContext,
    required int certificateId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + SalaryCertificateApis.getSalaryCertificateDetails,
        data: {
          'suconn': userContext.companyConnection,
          'id': certificateId,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      final salaryCertificateData =
          response.data['data'] as Map<String, dynamic>;
      return SalaryCertificateDetailsModel.fromJson(salaryCertificateData);
    });
  }
}
