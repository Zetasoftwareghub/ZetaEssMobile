import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/api_constants/self_service_apis/expense_claim_form_apis.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/features/self_service/expense_claim_form/models/advance_model.dart';
import 'package:zeta_ess/features/self_service/expense_claim_form/models/claim_list_response.dart';
import 'package:zeta_ess/features/self_service/expense_claim_form/models/expense_detail_model.dart';
import 'package:zeta_ess/features/self_service/expense_claim_form/models/save_claim_model.dart';

import '../../expense_claim/models/expense_claim_details.dart';
import '../models/currency_model.dart';

final claimRepositoryProvider = Provider<ClaimRepository>((ref) {
  return ClaimRepository();
});

class ClaimRepository {
  final dio = Dio();

  FutureEither<ClaimListResponse> getExpenseClaimList({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final data = {
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        'emcode': userContext.empCode,
        'escode': userContext.esCode,
      };
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimFormApis.getList,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ClaimListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load Expense Claim list');
      }
    });
  }

  FutureEither<List<dynamic>> bindExpenseCategoryGroup({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimFormApis.bindExpenseCategoryGroup,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load Expense Category Groups');
      }
    });
  }

  FutureEither<List<dynamic>> bindExpenseCategory({
    required UserContext userContext,
    required String groupId,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimFormApis.bindExpenseCategory,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'id': groupId,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load Expense Categories');
      }
    });
  }
  //
  //
  // FutureEither<List<AdvanceModel>> bindAdvanceNumber({
  //   required UserContext userContext,
  // }) {
  //   return handleApiCall(() async {
  //     final response = await dio.post(
  //       userContext.baseUrl + ExpenseClaimFormApis.bindAdvanceNumber,
  //       data: {
  //         'sucode': userContext.companyCode,
  //         'suconn': userContext.companyConnection,
  //         'emcode': userContext.empCode,
  //       },
  //       options: dioHeader(token: userContext.jwtToken),
  //     );
  //     if (response.statusCode == 200 && response.data['success'] == true) {
  //       final List<dynamic> data = response.data['data'];
  //       return data.map((e) => AdvanceModel.fromJson(e)).toList();
  //     } else {
  //       throw Exception('Failed to load Advance Numbers');
  //     }
  //   });
  // }

  FutureEither<String> saveExpClaimForm({
    required UserContext userContext,
    required SaveClaimModel saveClaimModel,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimFormApis.saveExpClaimForm,
        data: saveClaimModel.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['message'] ?? 'Saved Successfully';
      } else {
        throw Exception('Failed to save Expense Claim');
      }
    });
  }

  FutureEither<String> deleteExpClaimForm({
    required UserContext userContext,
    required int id,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimFormApis.deleteExpClaimForm,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'exmtid': id,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] ?? 'Could not delete Expense Claim';
      } else {
        throw Exception('Failed to delete Expense Claim');
      }
    });
  }

  FutureEither<ExpenseDetailModel> getExpClaimFormDetails({
    required UserContext userContext,
    required String id,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimFormApis.details,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'id': id,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExpenseDetailModel.fromJson(response.data['data'][0]);
      } else {
        throw Exception('Failed to load Expense Claim Details');
      }
    });
  }

  FutureEither<List<dynamic>> bindBusinessDescription({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimFormApis.bindBusinessDescription,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load Business Descriptions');
      }
    });
  }

  FutureEither<List<CurrencyModel>> bindCurrency({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ExpenseClaimFormApis.bindCurrency,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'][0] ?? [];
        return data.map((e) => CurrencyModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load Currencies');
      }
    });
  }
}
