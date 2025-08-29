import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/features/self_service/loan/models/loan_submit_model.dart';
import 'package:zeta_ess/features/self_service/loan/providers/loan_providers.dart';
import 'package:zeta_ess/features/self_service/loan/repository/loan_repository.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../core/common/widgets/customFilePicker_widget.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';

final loanControllerProvider = NotifierProvider<LoanController, bool>(() {
  return LoanController();
});

class LoanController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> submitLoan({
    required LoanSubmitRequestModel submitModel,
    required BuildContext context,
  }) async {
    state = true;

    final res = await ref
        .read(loanRepositoryProvider)
        .submitLoan(
          submitModel: submitModel,
          userContext: ref.read(userContextProvider),
        );
    state = false;

    res.fold(
      (error) {
        showCustomAlertBox(context, title: error.errMsg, type: AlertType.error);
      },
      (msg) {
        ref.invalidate(loanListProvider);
        if (msg?.toLowerCase() == 'saved successfully' ||
            msg?.toLowerCase() == 'updated successfully') {
          ref.read(fileUploadProvider.notifier).clearFile();
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

  Future<void> deleteLoan({
    required int loanId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(loanRepositoryProvider)
        .deleteLoan(
          userContext: ref.watch(userContextProvider),
          loanId: loanId,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(context: context, content: 'Error occured in deleting');
      },
      (deleted) {
        ref.invalidate(loanListProvider);
        showSnackBar(
          context: context,
          content: deleted ?? 'Cannot delete'.tr(),
        );
      },
    );
  }
}

/*import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/features/self_service/Loan_request/providers/Loan_provider.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';
import '../models/submit_Loan_model.dart';
import '../repository/Loan_repostiory.dart';

final LoanControllerProvider = NotifierProvider<LoanController, bool>(() {
  return LoanController();
});

class LoanController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> submitLoan({
    required SubmitLoanRequest submitModel,
    required BuildContext context,
  }) async {
    state = true;

    final res = await ref
        .read(LoanRepositoryProvider)
        .submitLoan(
          submitModel: submitModel,
          userContext: ref.read(userContextProvider),
        );
    state = false;

    res.fold(
      (error) {
        showCustomAlertBox(context, title: error.errMsg, type: AlertType.error);
      },
      (msg) {
        ref.invalidate(LoanListProvider);
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

}
*/
