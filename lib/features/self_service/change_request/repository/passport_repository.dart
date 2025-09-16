import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/api_constants/self_service_apis/change_request_apis.dart';
import 'package:zeta_ess/features/self_service/change_request/models/passport_model.dart';

import '../../../../core/error_handling/type_defs.dart';
import '../../../../core/providers/userContext_provider.dart';

final passportRepositoryProvider = Provider<PassportRepository>(
  (ref) => PassportRepository(),
);

class PassportRepository {
  final dio = Dio();

  FutureEither<PassportDetails> getPassportDetails({
    required UserContext userContext,
    String? employeeCode,
  }) {
    print(userContext.empCode);
    print(userContext.companyConnection);
    print('userContext.empCode');
    return handleApiCall(() async {
      final res = await dio.post(
        userContext.baseUrl + ChangeRequestApis.getPassportDetails,
        options: dioHeader(token: userContext.jwtToken),
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'emcode': employeeCode ?? userContext.empCode,
        },
      );
      if (res.statusCode == 200 && res.data['success'] == true) {
        return PassportDetails.fromJson(res.data['data'][0][0]);
      } else {
        throw Exception('Failed to load passport details');
      }
    });
  }
}
