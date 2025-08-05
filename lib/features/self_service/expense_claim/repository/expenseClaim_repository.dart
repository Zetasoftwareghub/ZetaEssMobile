import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';

import '../../../../core/api_constants/dio_headers.dart';
import '../../../../core/api_constants/self_service_apis/expense_claim_apis.dart';
import '../../../../core/error_handling/dio_errors.dart';
import '../../../../core/error_handling/failure.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/allowance_type_model.dart';
import '../models/expense_claim_model.dart';

final expenseClaimRepositoryProvider = Provider<ExpenseClaimRepository>((ref) {
  return ExpenseClaimRepository();
});

class ExpenseClaimRepository {
  final dio = Dio();

  FutureEither<ExpenseClaimListResponse> getExpenseClaimList({
    required UserContext userContext,
  }) async {
    try {
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimApis.getExpenseClaims,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'userid': userContext.esCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return right(ExpenseClaimListResponse.fromJson(response.data));
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

  FutureEither<String> submitExpenseClaim({
    required UserContext userContext,
    required ExpenseClaimModel expenseClaim,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimApis.submitExpenseClaim,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': int.parse(userContext.empCode),
          'username': userContext.empName,
          "baseDirectory": '', //TODO give this ! frmo locall
          ...expenseClaim.toJson(),
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      return response.data['data'].toString();
    });
  }

  FutureEither<bool> deleteExpenseClaim({
    required UserContext userContext,
    required int claimId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimApis.deleteExpenseClaims,
        data: {
          'suconn': userContext.companyConnection,
          'id': claimId,
          'escode': userContext.esCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      return response.data['data'].toString().toLowerCase() == 'true';
    });
  }

  FutureEither<ExpenseClaimModel> getExpenseClaimDetails({
    required UserContext userContext,
    required int claimId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimApis.getExpenseClaimDetails,
        data: {
          'suconn': userContext.companyConnection,
          'id': claimId,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      print(response.data['data'][0]);
      final expenseClaimData = response.data['data'][0] as Map<String, dynamic>;
      return ExpenseClaimModel.fromJson(expenseClaimData);
    });
  }

  FutureEither<List<AllowanceTypeModel>> getAllowanceTypes({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final baseUrl = userContext.baseUrl + ExpenseClaimApis.getAllowanceTypes;
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
  }
}
