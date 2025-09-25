import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_lieu_day_listing_model.dart';
import '../repository/approve_lieu_day_repository.dart';

final approveLieuDayListProvider = AutoDisposeAsyncNotifierProvider<
  ApproveLieuDayListNotifier,
  ApproveLieuDayListResponse
>(ApproveLieuDayListNotifier.new);

class ApproveLieuDayListNotifier
    extends AutoDisposeAsyncNotifier<ApproveLieuDayListResponse> {
  @override
  Future<ApproveLieuDayListResponse> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveLieuDayRepositoryProvider);
    final result = await repo.getApproveLieuDayList(userContext: userContext);
    return result.fold((failure) => throw failure, (data) => data);
  }
}

final approveLieuDayControllerProvider =
    NotifierProvider<ApproveLieuController, bool>(() {
      return ApproveLieuController();
    });

class ApproveLieuController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> approveRejectLieu({
    required String note,
    required String requestId,
    required String approveRejectFlag,
    required BuildContext context,
  }) async {
    state = true;
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveLieuDayRepositoryProvider);
    final result = await repo.approveRejectLieu(
      userContext: userContext,
      note: note,
      requestId: requestId,
      approveRejectFlag: approveRejectFlag,
    );
    state = false;

    return result.fold(
      (failure) => showSnackBar(context: context, content: failure.errMsg),
      (res) {
        ref.invalidate(approveLieuDayListProvider);

        if (res == 'Lieu Day approved Successfully' ||
            res == 'Lieu Day rejected Successfully') {
          //TODO check if this is correct !
          Navigator.pop(context);
        }
        showSnackBar(
          context: context,
          content: res ?? 'Request processed successfully',
        );
      },
    );
  }
}
