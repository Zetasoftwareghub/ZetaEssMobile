import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/features/self_service/expense_claim/controller/expenseClaim_controller.dart';

import '../models/allowance_type_model.dart';
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

// //TODO new remove above code
// final expenseDetailsProvider =
//     StateNotifierProvider<ExpenseDetailsNotifier, List<ExpenseDetail>>((ref) {
//       return ExpenseDetailsNotifier();
//     });
//
// class ExpenseDetailsNotifier extends StateNotifier<List<ExpenseDetail>> {
//   ExpenseDetailsNotifier() : super([]);
//
//   void addExpense(ExpenseDetail detail) {
//     state = [...state, detail];
//   }
//
//   void removeExpense(int index) {
//     state = List.from(state)..removeAt(index);
//   }
// }

// expense_detail_model.dart
class ExpenseDetailModel {
  final String id;
  final String date;
  final String description;
  final String currency;
  final String expenseAmount;
  final String costCenter;
  final String expenseAnalysis;
  final String amountInEmployeeCurrency;

  ExpenseDetailModel({
    required this.id,
    required this.date,
    required this.description,
    required this.currency,
    required this.expenseAmount,
    required this.costCenter,
    required this.expenseAnalysis,
    required this.amountInEmployeeCurrency,
  });

  ExpenseDetailModel copyWith({
    String? id,
    String? date,
    String? description,
    String? currency,
    String? expenseAmount,
    String? costCenter,
    String? expenseAnalysis,
    String? amountInEmployeeCurrency,
  }) {
    return ExpenseDetailModel(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      currency: currency ?? this.currency,
      expenseAmount: expenseAmount ?? this.expenseAmount,
      costCenter: costCenter ?? this.costCenter,
      expenseAnalysis: expenseAnalysis ?? this.expenseAnalysis,
      amountInEmployeeCurrency:
          amountInEmployeeCurrency ?? this.amountInEmployeeCurrency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'description': description,
      'currency': currency,
      'expenseAmount': expenseAmount,
      'costCenter': costCenter,
      'expenseAnalysis': expenseAnalysis,
      'amountInEmployeeCurrency': amountInEmployeeCurrency,
    };
  }

  factory ExpenseDetailModel.fromJson(Map<String, dynamic> json) {
    return ExpenseDetailModel(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      currency: json['currency'] ?? '',
      expenseAmount: json['expenseAmount'] ?? '',
      costCenter: json['costCenter'] ?? '',
      expenseAnalysis: json['expenseAnalysis'] ?? '',
      amountInEmployeeCurrency: json['amountInEmployeeCurrency'] ?? '',
    );
  }

  // Calculate total amount for summary
  double get totalAmount {
    try {
      return double.parse(expenseAmount.isEmpty ? '0' : expenseAmount);
    } catch (e) {
      return 0.0;
    }
  }
}

// expense_details_provider.dart

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
