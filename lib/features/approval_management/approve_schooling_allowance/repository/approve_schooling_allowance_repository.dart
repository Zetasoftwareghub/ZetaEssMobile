import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_schooling_allowance_listing_model.dart';

final approveSchoolingAllowanceRepositoryProvider =
    Provider<ApproveSchoolingAllowanceRepository>((ref) {
      return ApproveSchoolingAllowanceRepository();
    });

class ApproveSchoolingAllowanceRepository {
  final dio = Dio();

  FutureEither<ApproveSchoolingAllowanceListResponse>
  getApproveSchoolingAllowanceList({required UserContext userContext}) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl,
        // + ApproveApis.getApproveSchoolingAllowanceList,
        data: {
          'userid': userContext.esCode,
          'sucode' : userContext.companyCode,'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApproveSchoolingAllowanceListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load ApproveSchoolingAllowance list');
      }
    });
  }
}
