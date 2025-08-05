import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/self_service_apis/other_request_apis.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';
import 'package:zeta_ess/features/self_service/other_request/models/form_field_model.dart';
import 'package:zeta_ess/features/self_service/other_request/models/other_request_listing_model.dart';
import 'package:zeta_ess/features/self_service/other_request/models/submit_other_request_model.dart';

import '../../../../core/api_constants/dio_headers.dart';
import '../../../../core/providers/userContext_provider.dart';

final otherRequestRepositoryProvider = Provider<OtherRequestRepository>(
  (ref) => OtherRequestRepository(),
);

class OtherRequestRepository {
  final dio = Dio();

  FutureEither<List<OtherRequestFirstListingModel>> getFirstOtherRequestList({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + OtherRequestApis.getOtherRequestFirstListing,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'];
        return dataList
            .map((json) => OtherRequestFirstListingModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load lieu days');
      }
    });
  }

  FutureEither<OtherRequestListResponse> getOtherRequestList({
    required UserContext userContext,
    required String? requestId,
    required String? micode,
  }) async {
    return handleApiCall(() async {
      print(userContext.empCode);
      print(userContext.esCode);
      print(requestId);
      print(micode);
      print('micode');
      final response = await dio.post(
        userContext.baseUrl + OtherRequestApis.getOtherRequestList,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'userid': userContext.esCode,
          'rfcode': requestId,
          'micode': micode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return OtherRequestListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lieu days');
      }
    });
  }

  FutureEither<FormResponseModel> getOtherRequestForm({
    required UserContext userContext,
    required String? requestId,
    required String? micode,
  }) {
    print(requestId);
    print(micode);
    print('micode');
    print(userContext.empCode);
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + OtherRequestApis.getOtherRequestForm,
        data: {
          "rtencd": micode,
          "rqtmcd": requestId,
          "micode": '0',
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      print(response.data);
      print('response.data');
      if (response.statusCode == 200 && response.data['success'] == true) {
        print(response.data['data']['canLst']);
        print(response.data['data']['appLst']);
        return FormResponseModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load other request form');
      }
    });
  }

  FutureEither<String?> submitOtherRequest({
    required List<SubmitOtherRequestModel> submitModel,
    required UserContext userContext,
    required String rtencd,
    required String rfcode,
    required String emCode,
    required String micode,
    required String suconn,
    required String requestName,
    required String baseDirectory,
    required String emmail,
    required String empMail,
  }) async {
    return handleApiCall(() async {
      final payload = {
        "dtldata": submitModel.map((e) => e.toJson()).toList(),
        "rtencd": rtencd,
        "rfcode": rfcode,
        "emCode": emCode,
        "micode": micode,
        "suconn": suconn,
        "requestName": requestName,
        "baseDirectory": baseDirectory,
        "emmail": emmail,
        "emp_mail": empMail,
      };
      final prettyPayload = const JsonEncoder.withIndent('  ').convert(payload);
      print("🚀 Payload being sent:\n$prettyPayload");

      final response = await dio.post(
        userContext.baseUrl + OtherRequestApis.submitOtherRequest,
        data: payload,
        options: dioHeader(token: userContext.jwtToken),
      );
      print(response);
      print("response");
      print(response.data);
      print('response.data');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as String?;
      } else {
        return 'Failed to submit other request';
      }
    });
  }

  /*
  FutureEither<OtherRequestDetailsModel> getOtherRequestDetails({
    required UserContext userContext,
    required String OtherRequestId,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + OtherRequestApis.getOtherRequestDetails,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'rqldcode': OtherRequestId,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return OtherRequestDetailsModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load lieu days');
      }
    });
  }
*/
  FutureEither<String> deleteOtherRequest({
    required UserContext userContext,
    required String? primeKey,
    required String? micode,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + OtherRequestApis.deleteOtherRequest,
        data: {
          "primekey": primeKey,
          "micode": micode,
          "suconn": userContext.companyConnection,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      return response.data['data'];
    });
  }
}
