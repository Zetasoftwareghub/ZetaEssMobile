//
// class SubmittedLeavesNotifier
//     extends AutoDisposeAsyncNotifier<SubmittedLeaveResponse> {
//   @override
//   FutureOr<SubmittedLeaveResponse> build() async {
//     final repo = ref.read(leaveRepositoryProvider);
//     final userContext = ref.read(userContextProvider);
//
//     final result = await repo.getSubmittedLeaves(userContext: userContext);
//     return result.fold(
//           (failure) => throw Exception(failure.errMsg),
//           (data) => data,
//     );
//   }
// }

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/approval_management/approveExpense_claim/controller/approve_expense_claim_controller.dart';
import 'package:zeta_ess/features/approval_management/approveExpense_claim/repository/approve_expense_claim_repository.dart';
import 'package:zeta_ess/features/self_service/expense_claim/providers/expense_claim_providers.dart';
import 'package:zeta_ess/features/self_service/expense_claim/repository/expenseClaim_repository.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/allowance_type_model.dart';
import '../models/expense_claim_model.dart';

final expenseClaimControllerProvider =
    NotifierProvider<ExpenseClaimController, bool>(
      () => ExpenseClaimController(),
    );

class ExpenseClaimController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> submitExpenseClaim({
    required ExpenseClaimModel expenseClaim,
    required BuildContext context,
    required bool isEditMode,
  }) async {
    state = true;
    final res = await ref
        .read(expenseClaimRepositoryProvider)
        .submitExpenseClaim(
          userContext: ref.watch(userContextProvider),
          expenseClaim: expenseClaim,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(context: context, content: 'Error occurred : ${l.errMsg}');
      },
      (response) {
        ref.invalidate(expenseClaimListProvider);

        if (response == '1') {
          Navigator.pop(context);

          showSnackBar(
            context: context,
            content:
                isEditMode
                    ? 'expense_claim'.tr() + 'updated successfully'.tr()
                    : 'expense_claim'.tr() + 'submitted'.tr(),
          );
        } else {
          showCustomAlertBox(context, title: response.toString());
        }
      },
    );
  }

  Future<void> deleteExpenseClaim({
    required int claimId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(expenseClaimRepositoryProvider)
        .deleteExpenseClaim(
          userContext: ref.watch(userContextProvider),
          claimId: claimId,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(context: context, content: 'Error occured in deleting');
      },
      (deleted) {
        ref.invalidate(
          expenseClaimListProvider,
        ); //TODO is this correct to referesh after deleating? //
        showSnackBar(
          context: context,
          content: deleted ? 'Deleted successfully' : 'Cannot delete'.tr(),
        );
      },
    );
  }

  Future<void> approveExpenseClaim({
    required BuildContext context,
    required String comment,
    required String requestId,
    required String approveAmount,
    required String approveMonthYear,
    required ExpenseClaimModel expenseClaim,
  }) async {
    state = true;
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveExpenseClaimRepositoryProvider);

    final result = await repo.approveExpenseClaim(
      userContext: userContext,
      note: comment,
      requestId: requestId,
      expenseClaim: expenseClaim,
      approveAmount: approveAmount,
      approveMonthYear: approveMonthYear,
    );

    state = false;
    return result.fold(
      (failure) {
        showSnackBar(context: context, content: failure.errMsg);
      },
      (response) {
        ref.invalidate(approveExpenseClaimListProvider);
        if (response == '1' || (response ?? 'not').contains('Approved')) {
          Navigator.pop(context);
        }
        showSnackBar(
          context: context,
          content: response ?? 'Something happened',
        );
      },
    );
  }

  Future<void> rejectExpenseClaim({
    required BuildContext context,
    required String comment,
    required ExpenseClaimModel expenseClaim,
  }) async {
    state = true;
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveExpenseClaimRepositoryProvider);

    final result = await repo.rejectExpenseClaim(
      userContext: userContext,
      note: comment,
      expenseClaim: expenseClaim,
    );

    state = false;
    return result.fold(
      (failure) {
        showSnackBar(context: context, content: failure.errMsg);
      },
      (response) {
        ref.invalidate(approveExpenseClaimListProvider);
        if (response == '1' || (response ?? '').contains('Rejected')) {
          Navigator.pop(context);
        }
        showSnackBar(
          context: context,
          content: response ?? 'Something happened',
        );
      },
    );
  } //TODO check
}

class ExpenseClaimListNotifier extends AsyncNotifier<ExpenseClaimListResponse> {
  @override
  Future<ExpenseClaimListResponse> build() async {
    final repo = ref.read(expenseClaimRepositoryProvider);
    final userContext = ref.read(userContextProvider);
    final result = await repo.getExpenseClaimList(userContext: userContext);
    return result.fold((l) => throw l.errMsg, (r) => r);
  }
}

class AllowanceTypesNotifier
    extends AutoDisposeAsyncNotifier<List<AllowanceTypeModel>> {
  @override
  FutureOr<List<AllowanceTypeModel>> build() async {
    final repo = ref.read(expenseClaimRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getAllowanceTypes(userContext: userContext);
    return result.fold((l) => throw l.errMsg, (r) => r);
  }
}

class ExpenseClaimDetailsNotifier
    extends AutoDisposeFamilyAsyncNotifier<ExpenseClaimModel, int> {
  @override
  Future<ExpenseClaimModel> build(int claimId) async {
    final repo = ref.read(expenseClaimRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getExpenseClaimDetails(
      userContext: userContext,
      claimId: claimId,
    );

    return result.fold((failure) => throw failure.errMsg, (data) => data);
  }
}
