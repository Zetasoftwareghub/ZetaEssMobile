import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/resumption_leave_model.dart';
import '../models/resumption_listing_model.dart';
import '../repository/resumption_repository.dart';

class ResumptionLeavesNotifier
    extends AutoDisposeAsyncNotifier<List<ResumptionLeaveModel>> {
  @override
  Future<List<ResumptionLeaveModel>> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(resumptionRepositoryProvider);

    final result = await repo.getResumptionLeaves(userContext: userContext);

    return result.fold((failure) => throw failure, (data) => data);
  }
}

class ResumptionListNotifier
    extends AutoDisposeAsyncNotifier<ResumptionListResponse> {
  @override
  FutureOr<ResumptionListResponse> build() async {
    final userContext = ref.read(userContextProvider);

    final result = await ref
        .read(resumptionRepositoryProvider)
        .getResumptionList(userContext: userContext);

    return result.fold((failure) {
      throw failure.errMsg;
    }, (data) => data);
  }

  Future<void> refreshResumptionList() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userContext = ref.read(userContextProvider);
      final result = await ref
          .read(resumptionRepositoryProvider)
          .getResumptionList(userContext: userContext);
      return result.fold((failure) => throw failure, (data) => data);
    });
  }
}
