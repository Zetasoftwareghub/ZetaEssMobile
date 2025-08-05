import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_schooling_allowance_listing_model.dart';
import '../repository/approve_schooling_allowance_repository.dart';

final approveSchoolingAllowanceListProvider = AutoDisposeAsyncNotifierProvider<
  ApproveSchoolingAllowanceListNotifier,
  ApproveSchoolingAllowanceListResponse
>(ApproveSchoolingAllowanceListNotifier.new);

class ApproveSchoolingAllowanceListNotifier
    extends AutoDisposeAsyncNotifier<ApproveSchoolingAllowanceListResponse> {
  @override
  Future<ApproveSchoolingAllowanceListResponse> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveSchoolingAllowanceRepositoryProvider);
    final result = await repo.getApproveSchoolingAllowanceList(
      userContext: userContext,
    );
    return result.fold((failure) => throw failure, (data) => data);
  }
}
