import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/leave_model.dart';
import '../repository/leave_repository.dart';

class SubmittedLeavesNotifier
    extends AutoDisposeAsyncNotifier<SubmittedLeaveResponse> {
  @override
  FutureOr<SubmittedLeaveResponse> build() async {
    final repo = ref.read(leaveRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getSubmittedLeaves(userContext: userContext);
    return result.fold(
      (failure) => throw Exception(failure.errMsg),
      (data) => data,
    );
  }
}

class ApprovedLeavesNotifier
    extends AutoDisposeAsyncNotifier<List<LeaveModel>> {
  @override
  FutureOr<List<LeaveModel>> build() async {
    final repo = ref.read(leaveRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getApprovedLeaves(userContext: userContext);
    return result.fold((l) => throw l.errMsg, (r) => r);
  }
}

class RejectedLeavesNotifier
    extends AutoDisposeAsyncNotifier<List<LeaveModel>> {
  @override
  FutureOr<List<LeaveModel>> build() async {
    final repo = ref.read(leaveRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getRejectedLeaves(userContext: userContext);
    return result.fold((l) => throw l.errMsg, (r) => r);
  }
}

class CancelledLeavesNotifier
    extends AutoDisposeAsyncNotifier<List<LeaveModel>> {
  @override
  FutureOr<List<LeaveModel>> build() async {
    final repo = ref.read(leaveRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getCancelledLeaves(userContext: userContext);
    return result.fold((l) => throw l.errMsg, (r) => r);
  }
}
