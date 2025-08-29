import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';

import '../../../../core/api_constants/approval_manager_apis/approve_apis.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_loan_listing_model.dart';
import '../models/approve_loan_model.dart';

final approveLoanRepositoryProvider = Provider<ApproveLoanRepository>((ref) {
  return ApproveLoanRepository();
});

class ApproveLoanRepository {
  final dio = Dio();

  FutureEither<ApproveLoanListResponse> getApproveLoanList({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveLoanListApi,
        data: {
          'escode': userContext.esCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApproveLoanListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load ApproveLoan list');
      }
    });
  }

  FutureEither<String?> approveRejectLoan({
    required UserContext userContext,
    required ApproveLoanModel approveLoanModel,
  }) {
    print(approveLoanModel.toJson());
    print('approveLoanModel.toJson()');
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.approveRejectLoan,
        data: approveLoanModel.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to ApproveLieuDay request');
      }
    });
  }
  // FutureEither<String?> approveRejectLoan(){

  // }
}
