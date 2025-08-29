import 'package:flutter_riverpod/flutter_riverpod.dart';

// Add these models and providers to your existing expense_claim_providers.dart file

// Advance Payment Provider
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

// Business Gift Provider
class BusinessGiftsNotifier extends StateNotifier<List<BusinessGiftModel>> {
  BusinessGiftsNotifier() : super([]);

  void addBusinessGift(BusinessGiftModel gift) {
    state = [...state, gift];
  }

  void updateBusinessGift(String id, BusinessGiftModel updatedGift) {
    state = [
      for (final gift in state)
        if (gift.id == id) updatedGift else gift,
    ];
  }

  void removeBusinessGift(String id) {
    state = state.where((gift) => gift.id != id).toList();
  }

  double get totalGiftAmount {
    return state.fold(0.0, (sum, gift) => sum + gift.totalAmount);
  }
}

final businessGiftsProvider =
    StateNotifierProvider<BusinessGiftsNotifier, List<BusinessGiftModel>>((
      ref,
    ) {
      return BusinessGiftsNotifier();
    });

// You'll also need to add these models to your existing models file or create them

class AdvancePaymentModel {
  final String id;
  final String paymentNumber;
  final String currency;
  final String amount;
  final String conversionRate;
  final String amountInEmployeeCurrency;

  AdvancePaymentModel({
    required this.id,
    required this.paymentNumber,
    required this.currency,
    required this.amount,
    required this.conversionRate,
    required this.amountInEmployeeCurrency,
  });

  double get totalAmount => double.tryParse(amountInEmployeeCurrency) ?? 0.0;
}

class BusinessGiftModel {
  final String id;
  final String date;
  final String giftNumber;
  final String description;
  final String numberOfGuests;
  final String guestCompanyName;
  final String currency;
  final String expenseAmount;
  final String conversionRate;
  final String requestedConversionRate;
  final String amountInEmployeeCurrency;
  final String costCenter;

  BusinessGiftModel({
    required this.id,
    required this.date,
    required this.giftNumber,
    required this.description,
    required this.numberOfGuests,
    required this.guestCompanyName,
    required this.currency,
    required this.expenseAmount,
    required this.conversionRate,
    required this.requestedConversionRate,
    required this.amountInEmployeeCurrency,
    required this.costCenter,
  });

  double get totalAmount => double.tryParse(amountInEmployeeCurrency) ?? 0.0;
}
