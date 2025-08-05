import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_leave_listing_model.dart';
import '../repository/approve_leave_repository.dart';

final approveLeaveListProvider = AutoDisposeAsyncNotifierProvider<
  ApproveLeaveListNotifier,
  LeaveApprovalListResponse
>(ApproveLeaveListNotifier.new);

class ApproveLeaveListNotifier
    extends AutoDisposeAsyncNotifier<LeaveApprovalListResponse> {
  @override
  Future<LeaveApprovalListResponse> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveLeaveRepositoryProvider);
    final result = await repo.getApproveLeaveList(userContext: userContext);
    return result.fold((failure) => throw failure, (data) => data);
  }
}
