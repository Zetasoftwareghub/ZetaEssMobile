import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/api_constants/self_service_apis/change_request_apis.dart';
import 'package:zeta_ess/features/self_service/change_request/models/change_request_list_response.dart';

import '../../../../core/error_handling/type_defs.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/change_request_model.dart';
import '../models/change_request_types.dart';
import '../models/country_details_model.dart';

final changeRequestRepositoryProvider = Provider<ChangeRequestRepository>(
  (ref) => ChangeRequestRepository(),
);

class ChangeRequestRepository {
  final dio = Dio();

  FutureEither<String?> getMaritalStatus({
    String? empCode,
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ChangeRequestApis.getMaritalStatus,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': empCode ?? userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'][0][0]['emmast'].toString();
      } else {
        throw Exception('Failed to load marital status');
      }
    });
  }

  FutureEither<ChangeRequestListResponseModel> getChangeRequestListing({
    required UserContext userContext,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ChangeRequestApis.getChangeRequestList,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'escode': int.parse(userContext.esCode),
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ChangeRequestListResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load lieu days');
      }
    });
  }

  FutureEither<List<ChangeRequestTypeModel>> getRequestTypesList({
    required UserContext userContext,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ChangeRequestApis.getChangeRequestsDropDown,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'escode': userContext.esCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => ChangeRequestTypeModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load change request types');
      }
    });
  }

  FutureEither<String> submitChangeRequest({
    required UserContext userContext,
    required ChangeRequestModel saveModel,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ChangeRequestApis.submitChangeRequest,
        data: saveModel.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      print(response.data);
      print('updateProfileModel.toJson()');
      return response.data['data'].toString();
    });
  }

  FutureEither<List<CountryDetailsModel>> getCountryDetails({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ChangeRequestApis.getCountryDetails,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => CountryDetailsModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load country details');
      }
    });
  }

  FutureEither<String> deleteChangeRequest({
    required UserContext userContext,
    required int reqId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ChangeRequestApis.deleteChangeRequests,
        data: {'suconn': userContext.companyConnection, 'chrqcd': reqId},
        options: dioHeader(token: userContext.jwtToken),
      );
      print(response.data);
      print('response.data');
      return response.data['data'].toString();
    });
  }

  FutureEither<ChangeRequestModel> getChangeRequestDetails({
    required UserContext userContext,
    required int reqId,
  }) {
    final data = {
      'suconn': userContext.companyConnection,
      'iChrqcd': reqId,
      'emcode': userContext.empCode,
    };
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ChangeRequestApis.getChangeRequestDetails,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      return ChangeRequestModel.fromJson(response.data);
    });
  }

  /*


  FutureEither<List<AllowanceTypeModel>> getAllowanceTypes({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final baseUrl = userContext.baseUrl + ChangeRequestApis.getAllowanceTypes;
      final suconn = Uri.encodeComponent(userContext.companyConnection ?? '');
      final fullUrl = "$baseUrl?suconn=$suconn";

      final response = await dio.post(
        fullUrl,
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => AllowanceTypeModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load allowance types');
      }
    });
  }*/
}
