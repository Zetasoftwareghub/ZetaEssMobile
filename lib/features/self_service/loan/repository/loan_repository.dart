import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/self_service_apis/loan_apis.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/features/self_service/loan/models/loan_submit_model.dart';

import '../../../../core/api_constants/dio_headers.dart';
import '../models/loan_details_model.dart';
import '../models/loan_list_model.dart';
import '../models/loan_type_model.dart';

final loanRepositoryProvider = Provider<LoanRepository>(
  (ref) => LoanRepository(),
);

class LoanRepository {
  final dio = Dio();
  FutureEither<LoanListResponse> getLoanList({
    required UserContext userContext,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LoanApis.loanListApi,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'escode': int.parse(userContext.esCode),
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return LoanListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lieu days');
      }
    });
  }

  FutureEither<List<LoanTypeModel>> getLoanTypes({
    required UserContext userContext,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LoanApis.loanTypesApi,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'][0];
        return data.map((e) => LoanTypeModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load loan types');
      }
    });
  }

  FutureEither<LoanDetailModel> getLoanDetails({
    required UserContext userContext,
    required String loanId,
  }) async {
    final data = {
      'suconn': userContext.companyConnection,
      'emcode': userContext.empCode,
      'iLqslno': loanId,
    };
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LoanApis.loanDetailsApi,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return LoanDetailModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load lieu days');
      }
    });
  }

  FutureEither<String?> submitLoan({
    required LoanSubmitRequestModel submitModel,
    required UserContext userContext,
  }) async {
    print('aaa');
    return handleApiCall(() async {
      print(submitModel.toJson());
      print('submitModel.toJson()');
      final response = await dio.post(
        userContext.baseUrl + LoanApis.submitLoanApi,
        data: submitModel.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as String?;
      } else {
        return 'Failed to submit lieu day';
      }
    });
  }

  FutureEither<String?> deleteLoan({
    required UserContext userContext,
    required int loanId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + LoanApis.deleteLoanApi,
        data: {
          'suconn': userContext.companyConnection,
          'loid': loanId,
          'username': userContext.empName,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      return response.data['data'];
    });
  }
}
