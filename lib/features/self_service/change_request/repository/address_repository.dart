import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/api_constants/self_service_apis/change_request_apis.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';
import 'package:zeta_ess/features/self_service/change_request/models/address_model.dart';

import '../../../../core/providers/userContext_provider.dart';

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => AddressRepository(),
);

class AddressRepository {
  final dio = Dio();

  FutureEither<List> getCountryList({required UserContext userContext}) async {
    return handleApiCall(() async {
      final res = await dio.post(
        ChangeRequestApis.getCountryDetails,
        options: dioHeader(token: userContext.jwtToken),
        data: userContext.toJson(),
      );

      if (res.statusCode == 200 && res.data['success'] == true) {
        final List<dynamic> data = res.data['data'];
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception('Failed to load country list');
      }
    });
  }

  FutureEither<AddressContactModel> getAddressContactDetails({
    required UserContext userContext,
    String? employeeCode,
  }) async {
    return handleApiCall(() async {
      final res = await dio.post(
        userContext.baseUrl + ChangeRequestApis.getAddressContactDetails,
        options: dioHeader(token: userContext.jwtToken),
        data: {
          'suconn': userContext.companyConnection,
          'emcode': employeeCode ?? userContext.empCode,
        },
      );
      if (res.statusCode == 200 && res.data['success'] == true) {
        return AddressContactModel.fromJson(res.data['data'][0][0]);
      } else {
        throw Exception('Failed to load address contact details');
      }
    });
  }
}
