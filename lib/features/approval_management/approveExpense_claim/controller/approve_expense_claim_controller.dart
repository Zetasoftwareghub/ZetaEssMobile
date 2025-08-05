import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_expense_claim_listing_model.dart';
import '../repository/approve_expense_claim_repository.dart';

final approveExpenseClaimListProvider = AutoDisposeAsyncNotifierProvider<
  ApproveExpenseClaimListNotifier,
  ApproveExpenseClaimListResponse
>(ApproveExpenseClaimListNotifier.new);

class ApproveExpenseClaimListNotifier
    extends AutoDisposeAsyncNotifier<ApproveExpenseClaimListResponse> {
  @override
  Future<ApproveExpenseClaimListResponse> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveExpenseClaimRepositoryProvider);
    final result = await repo.getApproveExpenseClaimList(
      userContext: userContext,
    );
    return result.fold((failure) => throw failure, (data) => data);
  }
}
