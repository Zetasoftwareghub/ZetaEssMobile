import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/features/self_service/lieuDay_request/models/lieuDay_details_model.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/lieuDay_listing_model.dart';
import '../repository/lieuday_repostiory.dart';

class LieuDayListNotifier
    extends AutoDisposeAsyncNotifier<LieuDayListResponse> {
  @override
  Future<LieuDayListResponse> build() async {
    final repo = ref.read(lieuDayRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getLieuDayList(userContext: userContext);

    return result.fold((failure) => throw failure, (data) => data);
  }
}

final lieuDayDetailsFutureProvider = FutureProvider.autoDispose
    .family<LieuDayDetailsModel, String>((ref, lieuDayId) async {
      final repository = ref.read(lieuDayRepositoryProvider);

      final result = await repository.getLieuDayDetails(
        userContext: ref.read(userContextProvider),
        lieuDayId: lieuDayId,
      );

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (data) => data,
      );
    });
