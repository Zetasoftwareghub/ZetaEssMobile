import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api_constants/dio_headers.dart';
import '../../../../core/api_constants/self_service_apis/change_request_apis.dart';
import '../../../../core/error_handling/type_defs.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/bank_model.dart';

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankRepository();
});

class BankRepository {
  final dio = Dio();

  FutureEither<BankDetailsModel> getBankDetails({
    required UserContext userContext,
    String? employeeCode,
  }) async {
    return handleApiCall(() async {
      final res = await dio.post(
        userContext.baseUrl + ChangeRequestApis.getCurrentBankDetails,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'iEmpCode': employeeCode ?? userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (res.statusCode == 200 && res.data['success'] == true) {
        return BankDetailsModel.fromJson(res.data['data'][0][0]);
      } else {
        throw Exception('Failed to load bank details');
      }
    });
  }

  FutureEither<List<BankModel>> getBankList({
    required UserContext userContext,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ChangeRequestApis.bindBanksApi,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'][0];
        return data.map((e) => BankModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load bank list');
      }
    });
  }
}
