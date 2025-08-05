import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/features/approval_management/approve_salary_certificate/controller/approve_salary_certificate_controller.dart';
import 'package:zeta_ess/features/approval_management/approve_salary_certificate/repository/approve_salary_certificate_repository.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/models/salary_certificate_detail_model.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/models/submit_salary_certificate_model.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/repository/salary_certificate_repository.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';
import '../providers/salary_certificate_notifiers.dart';

final salaryCertificateControllerProvider =
    NotifierProvider<SalaryCertificateController, bool>(() {
      return SalaryCertificateController();
    });

class SalaryCertificateController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> submitSalaryCertificate({
    required SubmitSalaryCertificateModel submitModel,
    required BuildContext context,
  }) async {
    state = true;

    final res = await ref
        .read(salaryCertificateRepositoryProvider)
        .submitSalaryCertificate(
          submitModel: submitModel,
          userContext: ref.read(userContextProvider),
        );
    state = false;

    res.fold(
      (error) {
        showCustomAlertBox(context, title: error.errMsg, type: AlertType.error);
      },
      (msg) {
        ref.invalidate(salaryCertificateListProvider);
        if (msg == '1') {
          Navigator.pop(context);
          showCustomAlertBox(
            context,
            title: 'Submitted successfully',
            type: AlertType.success,
          );
        } else {
          showCustomAlertBox(context, title: msg, type: AlertType.warning);
        }
      },
    );
  }

  Future<void> deleteSalaryCertificate({
    required int salaryCertificateId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(salaryCertificateRepositoryProvider)
        .deleteSalaryCertificate(
          userContext: ref.watch(userContextProvider),
          salaryCertificateId: salaryCertificateId,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(context: context, content: 'Error occured in deleting');
      },
      (deleted) {
        showSnackBar(
          context: context,
          content: deleted ? 'Deleted successfully' : 'Cannot delete'.tr(),
        );
        ref.invalidate(salaryCertificateListProvider);
      },
    );
  }

  Future<void> approveRejectSalary({
    required String note,
    required String certificateId,
    required String approveRejectFlag,
    required SalaryCertificateDetailsModel salaryModel,
    required BuildContext context,
  }) async {
    state = true;
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveSalaryCertificateRepositoryProvider);
    final result = await repo.approveRejectSalaryCertificate(
      userContext: userContext,
      note: note,
      certificateId: certificateId,
      approveRejectFlag: approveRejectFlag,
      salaryModel: salaryModel,
    );
    state = false;

    return result.fold(
      (failure) => showSnackBar(context: context, content: failure.errMsg),
      (res) {
        ref.invalidate(approveSalaryCertificateListProvider);
        if (res == 'Approved Successfully' || res == 'Rejected Successfully') {
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
