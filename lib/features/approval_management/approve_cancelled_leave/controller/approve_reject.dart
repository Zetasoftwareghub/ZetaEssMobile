import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/utils.dart';

import '../models/cancel_leave_params.dart';
import '../repository/approve_cancel_leave_repository.dart';
import 'approve_cacncel_leave_controller.dart';

final approveRejectCancelLeaveProvider = AsyncNotifierProvider.autoDispose<
  ApproveRejectCancelLeaveController,
  String?
>(() => ApproveRejectCancelLeaveController());

class ApproveRejectCancelLeaveController
    extends AutoDisposeAsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    // no initial call
    return null;
  }

  Future<void> approveOrReject(
    ApproveRejectCancelLeaveParams params,
    BuildContext context,
  ) async {
    state = const AsyncLoading();
    final repo = ref.read(approveCancelLeaveRepositoryProvider);

    final result = await repo.approveOrRejectLeave(params: params);

    result.fold((failure) => state = AsyncError(failure, StackTrace.current), (
      message,
    ) {
      if (message == 'Leave cancellation approved successfully.' ||
          message == 'Leave cancellation rejected successfully.') {
        Navigator.pop(context);
      }
      showSnackBar(context: context, content: message ?? 'Something happened');
      ref.invalidate(approveCancelLeaveListProvider);
      return state = AsyncData(message);
    });
  }
}
