// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../models/advance_model.dart';
// import '../models/bussiness_gift_model.dart';
//
// class AdvancePaymentsNotifier extends StateNotifier<List<AdvancePaymentModel>> {
//   AdvancePaymentsNotifier() : super([]);
//
//   void addAdvancePayment(AdvancePaymentModel payment) {
//     state = [...state, payment];
//   }
//
//   void updateAdvancePayment(String id, AdvancePaymentModel updatedPayment) {
//     state = [
//       for (final payment in state)
//         if (payment.id == id) updatedPayment else payment,
//     ];
//   }
//
//   void removeAdvancePayment(String id) {
//     state = state.where((payment) => payment.id != id).toList();
//   }
//
//   double get totalAdvanceAmount {
//     return state.fold(0.0, (sum, payment) => sum + payment.totalAmount);
//   }
// }
//
// final advancePaymentsProvider =
//     StateNotifierProvider<AdvancePaymentsNotifier, List<AdvancePaymentModel?>>((
//       ref,
//     ) {
//       return AdvancePaymentsNotifier();
//     });
//
// // Business Gift Provider
// class BusinessGiftsNotifier extends StateNotifier<List<BusinessGiftModel>> {
//   BusinessGiftsNotifier() : super([]);
//
//   void addBusinessGift(BusinessGiftModel gift) {
//     state = [...state, gift];
//   }
//
//   void updateBusinessGift(String id, BusinessGiftModel updatedGift) {
//     state = [
//       for (final gift in state)
//         if (gift.id == id) updatedGift else gift,
//     ];
//   }
//
//   void removeBusinessGift(String id) {
//     state = state.where((gift) => gift.id != id).toList();
//   }
//
//   double get totalGiftAmount {
//     return state.fold(0.0, (sum, gift) => sum + gift.totalAmount);
//   }
// }
//
// final businessGiftsProvider =
//     StateNotifierProvider<BusinessGiftsNotifier, List<BusinessGiftModel>>((
//       ref,
//     ) {
//       return BusinessGiftsNotifier();
//     });
