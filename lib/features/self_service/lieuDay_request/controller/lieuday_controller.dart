import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/features/self_service/lieuDay_request/providers/lieuDay_provider.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';
import '../models/submit_lieuDay_model.dart';
import '../repository/lieuday_repostiory.dart';

final lieuDayControllerProvider = NotifierProvider<LieuDayController, bool>(() {
  return LieuDayController();
});

class LieuDayController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> submitLieuDay({
    required SubmitLieuDayRequest submitModel,
    required BuildContext context,
  }) async {
    state = true;

    final res = await ref
        .read(lieuDayRepositoryProvider)
        .submitLieuDay(
          submitModel: submitModel,
          userContext: ref.read(userContextProvider),
        );
    state = false;

    res.fold(
      (error) {
        showCustomAlertBox(context, title: error.errMsg, type: AlertType.error);
      },
      (msg) {
        ref.invalidate(lieuDayListProvider);
        if (msg?.toLowerCase() == 'saved successfully' ||
            msg?.toLowerCase() == 'updated successfully') {
          Navigator.pop(context);
          showCustomAlertBox(
            context,
            title: msg ?? 'Submitted',
            type: AlertType.success,
          );
          return;
        } else {
          showCustomAlertBox(
            context,
            title: msg ?? 'Something went wrong',
            type: AlertType.warning,
          );
        }
      },
    );
  }

  Future<void> deleteLieuDay({
    required int lieuDayId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(lieuDayRepositoryProvider)
        .deleteLieuDay(
          userContext: ref.watch(userContextProvider),
          lieuDayId: lieuDayId,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(context: context, content: 'Error occured in deleting');
      },
      (deleted) {
        ref.invalidate(
          lieuDayListProvider,
        ); //TODO is this correct to referesh after deleating? //
        showSnackBar(
          context: context,
          content: deleted ? 'Deleted successfully' : 'Cannot delete'.tr(),
        );
      },
    );
  }
}
