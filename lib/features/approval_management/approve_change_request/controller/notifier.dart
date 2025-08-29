import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_listing_model.dart';
import '../repository/approve_change_request_repository.dart';

final approveChangeRequestListProvider = AutoDisposeAsyncNotifierProvider<
  ApproveChangeRequestListNotifier,
  ApproveChangeRequestListResponseModel
>(ApproveChangeRequestListNotifier.new);

class ApproveChangeRequestListNotifier
    extends AutoDisposeAsyncNotifier<ApproveChangeRequestListResponseModel> {
  @override
  Future<ApproveChangeRequestListResponseModel> build() async {
    final userContext = ref.watch(userContextProvider);
    return await _fetch(userContext);
  }

  Future<ApproveChangeRequestListResponseModel> _fetch(
    UserContext userContext,
  ) async {
    final repo = ref.read(approveChangeRequestRepositoryProvider);
    final res = await repo.getApproveChangeRequestListing(
      userContext: userContext,
    );
    return res.fold((l) => throw Exception(l.errMsg), (r) => r);
  }

  // For future step - approve request
  Future<void> approveRequest(int requestCode) async {
    // TODO: Call approve API here
    // After approving, refresh list
    final userContext = ref.read(userContextProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(userContext));
  }
}
