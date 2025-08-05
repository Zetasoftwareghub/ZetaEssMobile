import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/other_request_listing_model.dart';
import '../repository/other_request_repository.dart';

class OtherRequestFirstListingNotifier
    extends AutoDisposeAsyncNotifier<List<OtherRequestFirstListingModel>> {
  @override
  Future<List<OtherRequestFirstListingModel>> build() async {
    final userContext = ref.watch(userContextProvider);
    final repository = ref.watch(otherRequestRepositoryProvider);

    final result = await repository.getFirstOtherRequestList(
      userContext: userContext,
    );

    return result.fold(
      (failure) => throw Exception(failure.errMsg),
      (otherList) => otherList,
    );
  }
}

class OtherRequestListNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          OtherRequestListResponse,
          OtherRequestParams
        > {
  @override
  Future<OtherRequestListResponse> build(OtherRequestParams arg) async {
    final repo = ref.read(otherRequestRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getOtherRequestList(
      userContext: userContext,
      requestId: arg.requestId,
      micode: arg.micode,
    );

    return result.fold((failure) => throw failure, (data) => data);
  }
}

class OtherRequestParams {
  final String? requestId;
  final String? micode;

  OtherRequestParams({required this.requestId, required this.micode});
}
