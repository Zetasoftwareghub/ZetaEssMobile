import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/features/self_service/other_request/models/submit_other_request_model.dart';
import 'package:zeta_ess/features/self_service/other_request/providers/other_request_providers.dart';
import 'package:zeta_ess/features/self_service/other_request/repository/other_request_repository.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';

final otherRequestControllerProvider =
    NotifierProvider<OtherRequestController, bool>(() {
      return OtherRequestController();
    });

class OtherRequestController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> submitOtherRequest({
    required List<SubmitOtherRequestModel> submitModel,
    required BuildContext context,
    required String rtencd,
    required String rqtmcd,
    required String micode,
    String? menuName,
  }) async {
    state = true;

    final res = await ref
        .read(otherRequestRepositoryProvider)
        .submitOtherRequest(
          submitModel: submitModel,
          userContext: ref.read(userContextProvider),
          rtencd: rtencd ?? '',
          rfcode: rqtmcd ?? '',
          emCode: ref.watch(userContextProvider).empCode,
          micode: micode ?? '',
          suconn: ref.watch(userContextProvider).companyConnection ?? '',
          requestName: menuName ?? 'Other Request',
          baseDirectory: ref.watch(userContextProvider).userBaseUrl ?? '',
          emmail: ref.watch(userContextProvider).empEminid,
          empMail: ref.watch(userContextProvider).empEminid,
        );
    state = false;

    res.fold(
      (error) {
        showCustomAlertBox(context, title: error.errMsg, type: AlertType.error);
      },
      (msg) {
        ref.invalidate(otherRequestListProvider);
        if (msg?.toLowerCase() == 'saved successfully' ||
            msg?.toLowerCase() == 'updated successfully') {
          Navigator.pop(context);
          showCustomAlertBox(
            context,
            title: msg ?? 'Submitted',
            type: AlertType.success,
          );
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

  Future<void> deleteOtherRequest({
    required String? micode,
    required String? primeKey,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(otherRequestRepositoryProvider)
        .deleteOtherRequest(
          userContext: ref.watch(userContextProvider),
          primeKey: primeKey,
          micode: micode,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(context: context, content: 'Error occured in deleting');
      },
      (msg) {
        ref.invalidate(
          otherRequestListProvider,
        ); //TODO is this correct to referesh after deleating? //
        showSnackBar(context: context, content: msg);
      },
    );
  }
}
