import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_resumption_listing_model.dart';
import '../repository/approve_resumptio_repository.dart';

final approveResumptionListProvider = AutoDisposeAsyncNotifierProvider<
  ApproveResumptionListNotifier,
  ApproveResumptionListResponse
>(ApproveResumptionListNotifier.new);

class ApproveResumptionListNotifier
    extends AutoDisposeAsyncNotifier<ApproveResumptionListResponse> {
  @override
  Future<ApproveResumptionListResponse> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveResumptionRepositoryProvider);

    final result = await repo.getApproveResumptionList(
      userContext: userContext,
    );
    return result.fold((failure) => throw failure, (data) => data);
  }
}
