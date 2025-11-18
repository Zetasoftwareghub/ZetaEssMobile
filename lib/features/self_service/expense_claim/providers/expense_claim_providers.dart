import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/features/self_service/expense_claim/controller/expenseClaim_controller.dart';

import '../../expense_claim_form/models/expense_detail_model.dart';
import '../models/allowance_type_model.dart';
import '../models/expense_claim_details.dart';
import '../models/expense_claim_model.dart';

final allowanceTypesProvider = AutoDisposeAsyncNotifierProvider<
  AllowanceTypesNotifier,
  List<AllowanceTypeModel>
>(() => AllowanceTypesNotifier());

final expenseClaimListProvider = AutoDisposeAsyncNotifierProvider<
  ExpenseClaimListNotifier,
  ExpenseClaimListResponse
>(ExpenseClaimListNotifier.new);

final expenseClaimDetailsProvider = AsyncNotifierProvider.autoDispose
    .family<ExpenseClaimDetailsNotifier, ExpenseClaimModel, int>(
      ExpenseClaimDetailsNotifier.new,
    );

class ExpenseDetailsNotifier extends StateNotifier<List<ExpenseDetailModel>> {
  ExpenseDetailsNotifier() : super([]);

  void addExpenseDetail(ExpenseDetailModel expense) {
    state = [...state, expense];
  }

  void updateExpenseDetail(String id, ExpenseDetailModel updatedExpense) {
    state =
        state.map((expense) {
          return expense.id == id ? updatedExpense : expense;
        }).toList();
  }

  void removeExpenseDetail(String id) {
    state = state.where((expense) => expense.id != id).toList();
  }

  void clearAll() {
    state = [];
  }

  double get totalExpenseAmount {
    return state.fold(0.0, (sum, expense) => sum + expense.totalAmount);
  }
}

final expenseDetailsProvider =
    StateNotifierProvider<ExpenseDetailsNotifier, List<ExpenseDetailModel>>((
      ref,
    ) {
      return ExpenseDetailsNotifier();
    });
