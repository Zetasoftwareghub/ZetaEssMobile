import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';

import '../../../../core/api_constants/approval_manager_apis/approve_apis.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../self_service/expense_claim/models/expense_claim_model.dart';
import '../models/approve_expense_claim_listing_model.dart';

final approveExpenseClaimRepositoryProvider =
    Provider<ApproveExpenseClaimRepository>((ref) {
      return ApproveExpenseClaimRepository();
    });

class ApproveExpenseClaimRepository {
  final dio = Dio();

  FutureEither<ApproveExpenseClaimListResponse> getApproveExpenseClaimList({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveExpenseClaimList,
        data: {
          'userid': userContext.esCode,
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApproveExpenseClaimListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load ApproveExpenseClaim list');
      }
    });
  }

  FutureEither<String?> approveExpenseClaim({
    required UserContext userContext,
    required String note,
    required String requestId,
    required String approveAmount,
    required String approveMonthYear,
    required ExpenseClaimModel expenseClaim,
  }) {
    return handleApiCall(() async {
      final data = {
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        "id": requestId,
        "apremcode": userContext.empCode,
        "emcode": expenseClaim.empCode,
        "uname": expenseClaim.employeeName,
        "rqnote": expenseClaim.note,
        "apnote": note,
        "mnth": expenseClaim.month,
        "year": expenseClaim.year,
        "crcode": "INR",
        "conrate": 1.00,
        "apramnt": approveAmount,
        "rqdt": expenseClaim.reqdate,
        "rqamt": expenseClaim.amount,
        "cocode": 0,
        "url": "string",
        "apprMonthYear": approveMonthYear,
        "baseDirectory": "string",
      };
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.approveExpenseClaim,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to ApproveLieuDay request');
      }
    });
  }

  FutureEither<String?> rejectExpenseClaim({
    required UserContext userContext,
    required String note,
    required ExpenseClaimModel expenseClaim,
  }) {
    return handleApiCall(() async {
      final data = {
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        "id": expenseClaim.expenseClaimId,
        "apremcode": userContext.empCode,
        "emcode": expenseClaim.empCode,
        "uname": expenseClaim.employeeName,
        "rqnote": expenseClaim.note,
        "apnote": note,
        "mnthyr": "${expenseClaim.month}/${expenseClaim.year}",
        "crcode": "INR",
        "conrate": "1.00",
        "apramt": "0",
        "rqdt": expenseClaim.reqdate,
        "rqamt": expenseClaim.amount,
        "cocode": 0,
        "url": "string",
        "apprMonthYear": "",
        "baseDirectory": "string",
      };
      print(data);
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.rejectExpenseClaim,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to ApproveLieuDay request');
      }
    });
  }
}
