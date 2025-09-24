import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/features/approval_management/approve_cancelled_leave/models/cancel_leave_listing.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/cancel_leave_model.dart';
import '../models/cancel_leave_params.dart';
import '../repository/approve_cancel_leave_repository.dart';

final approveCancelLeaveListProvider = AutoDisposeAsyncNotifierProvider<
  ApproveLeaveListNotifier,
  ApproveCancelLeaveListResponse
>(ApproveLeaveListNotifier.new);

class ApproveLeaveListNotifier
    extends AutoDisposeAsyncNotifier<ApproveCancelLeaveListResponse> {
  @override
  Future<ApproveCancelLeaveListResponse> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveCancelLeaveRepositoryProvider);
    final result = await repo.getApproveCancelLeaveList(
      userContext: userContext,
    );
    return result.fold((failure) => throw failure, (data) => data);
  }
}

final cancelLeaveDetailsProvider = FutureProvider.autoDispose
    .family<CancelLeaveModel, CancelLeaveParams>((ref, arg) async {
      final repo = ref.read(approveCancelLeaveRepositoryProvider);
      print('123123');
      final result = await repo.getCancelLeaveDetails(
        userContext: arg.userContext,
        lsslno: arg.lsslno,
        laslno: arg.laslno,
        clslno: arg.clslno,
      );

      return result.fold((failure) => throw failure, (data) => data);
    });
