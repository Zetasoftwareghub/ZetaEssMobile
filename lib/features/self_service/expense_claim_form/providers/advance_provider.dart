import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/advance_model.dart';

class AdvancePaymentsNotifier extends StateNotifier<List<AdvancePaymentModel>> {
  AdvancePaymentsNotifier() : super([]);

  void addAdvancePayment(AdvancePaymentModel payment) {
    state = [...state, payment];
  }

  void updateAdvancePayment(String id, AdvancePaymentModel updatedPayment) {
    state = [
      for (final payment in state)
        if (payment.id == id) updatedPayment else payment,
    ];
  }

  void removeAdvancePayment(String id) {
    state = state.where((payment) => payment.id != id).toList();
  }

  double get totalAdvanceAmount {
    return state.fold(0.0, (sum, payment) => sum + payment.totalAmount);
  }
}

final advancePaymentsProvider =
    StateNotifierProvider<AdvancePaymentsNotifier, List<AdvancePaymentModel?>>((
      ref,
    ) {
      return AdvancePaymentsNotifier();
    });
