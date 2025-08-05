import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/features/self_service/leave_management/repository/leave_repository.dart';

import '../controller/leaveListin_controller.dart';
import '../controller/leave_controller.dart';
import '../models/leave_model.dart';

final totalLeaveDaysStateProvider = StateProvider.autoDispose<String>(
  (ref) => '0',
);

final getApproveLeaveDetailsProvider = FutureProvider.autoDispose
    .family<LeaveModel, String>((ref, leaveId) async {
      final userContext = ref.watch(userContextProvider);
      final result = await ref
          .read(leaveRepositoryProvider)
          .getApprovalLeaveDetails(userContext: userContext, leaveId: leaveId);

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (data) => data,
      );
    });

final getSelfLeaveDetailsProvider = FutureProvider.autoDispose
    .family<LeaveEditResponse, String>((ref, leaveId) async {
      final userContext = ref.watch(userContextProvider);
      final result = await ref
          .read(leaveRepositoryProvider)
          .getSelfLeaveDetails(userContext: userContext, leaveId: leaveId);

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (data) => data,
      );
    });

final submittedLeaveListProvider = AutoDisposeAsyncNotifierProvider<
  SubmittedLeavesNotifier,
  SubmittedLeaveResponse
>(SubmittedLeavesNotifier.new);

final approvedLeavesProvider =
    AutoDisposeAsyncNotifierProvider<ApprovedLeavesNotifier, List<LeaveModel>>(
      () => ApprovedLeavesNotifier(),
    );

final rejectedLeavesProvider =
    AutoDisposeAsyncNotifierProvider<RejectedLeavesNotifier, List<LeaveModel>>(
      () => RejectedLeavesNotifier(),
    );

final cancelledLeavesProvider =
    AutoDisposeAsyncNotifierProvider<CancelledLeavesNotifier, List<LeaveModel>>(
      () => CancelledLeavesNotifier(),
    );

final leaveTypesProvider =
    AutoDisposeAsyncNotifierProvider<LeaveTypesNotifier, List<LeaveTypeModel>>(
      () => LeaveTypesNotifier(),
    );

final submitLeaveNotifierProvider =
    AutoDisposeAsyncNotifierProvider<SubmitLeaveNotifier, String?>(
      () => SubmitLeaveNotifier(),
    );
