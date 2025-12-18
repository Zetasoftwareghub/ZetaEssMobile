import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bussiness_gift_model.dart';

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
