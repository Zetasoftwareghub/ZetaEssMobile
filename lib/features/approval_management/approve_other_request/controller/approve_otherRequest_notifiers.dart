import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_listing_model.dart';
import '../repository/approve_other_request_repository.dart';

final approveOtherRequestFirstListingProvider =
    AutoDisposeAsyncNotifierProvider<
      ApproveOtherRequestFirstListingNotifier,
      List<ApproveOtherRequestFirstListingModel>
    >(ApproveOtherRequestFirstListingNotifier.new);

final approveOtherRequestListProvider = AutoDisposeAsyncNotifierProviderFamily<
  ApproveOtherRequestListNotifier,
  ApproveOtherRequestListResponse,
  ApproveOtherRequestParams
>(ApproveOtherRequestListNotifier.new);

class ApproveOtherRequestFirstListingNotifier
    extends
        AutoDisposeAsyncNotifier<List<ApproveOtherRequestFirstListingModel>> {
  @override
  Future<List<ApproveOtherRequestFirstListingModel>> build() async {
    final userContext = ref.watch(userContextProvider);
    final repository = ref.watch(approveOtherRequestRepositoryProvider);

    final result = await repository.getFirstApproveOtherRequestList(
      userContext: userContext,
      // requestId: arg.requestId,
      // micode: arg.micode,
    );

    return result.fold(
      (failure) => throw Exception(failure.errMsg),
      (otherList) => otherList,
    );
  }
}

class ApproveOtherRequestListNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          ApproveOtherRequestListResponse,
          ApproveOtherRequestParams
        > {
  @override
  Future<ApproveOtherRequestListResponse> build(
    ApproveOtherRequestParams arg,
  ) async {
    final repo = ref.read(approveOtherRequestRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getApproveOtherRequestList(
      userContext: userContext,
      rfcode: arg.requestId ?? '0',
      micode: arg.micode ?? '0',
    );

    return result.fold(
      (failure) => throw Exception(failure.errMsg),
      (data) => data,
    );
  }
}

class ApproveOtherRequestParams {
  final String? requestId;
  final String? micode;

  ApproveOtherRequestParams({required this.requestId, required this.micode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApproveOtherRequestParams &&
          runtimeType == other.runtimeType &&
          requestId == other.requestId &&
          micode == other.micode;

  @override
  int get hashCode => requestId.hashCode ^ micode.hashCode;
}
