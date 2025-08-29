import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/widgets/customFilePicker_widget.dart';
import 'package:zeta_ess/features/approval_management/approve_resumption_request/controller/approve_resumption_controller.dart';
import 'package:zeta_ess/features/approval_management/approve_resumption_request/repository/approve_resumptio_repository.dart';
import 'package:zeta_ess/features/self_service/resumption_request/models/submit_resumption_model.dart';
import 'package:zeta_ess/features/self_service/resumption_request/providers/resumption_provider.dart';
import 'package:zeta_ess/features/self_service/resumption_request/repository/resumption_repository.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';

final resumptionControllerProvider =
    NotifierProvider<ResumptionController, bool>(() => ResumptionController());

class ResumptionController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> submitResumptionLeave({
    required SubmitResumptionModel submitResumptionModel,
    required BuildContext context,
    required bool isEditMode,
    bool isFromLeaveSubmit = false,
  }) async {
    state = true;
    final res = await ref
        .read(resumptionRepositoryProvider)
        .submitResumptionLeave(
          userContext: ref.watch(userContextProvider),
          resumptionModel: submitResumptionModel,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(context: context, content: 'Error occurred : ${l.errMsg}');
      },
      (response) {
        ref.invalidate(resumptionListProvider);
        if (response?.toLowerCase() == 'saved successfully' ||
            response?.toLowerCase() == 'updated successfully') {
          ref.read(fileUploadProvider.notifier).clearFile();

          Navigator.pop(context);
          showCustomAlertBox(
            context,
            title:
                isFromLeaveSubmit
                    ? 'Resumption and Leave Submitted' //TODO check this correctly and give for tessting
                    : isEditMode
                    ? 'resumption_request'.tr() + 'updated successfully'.tr()
                    : 'resumption_request'.tr() + 'submitted'.tr(),
            type: AlertType.success,
          );
        } else {
          showCustomAlertBox(context, title: response.toString());
        }
      },
    );
  }

  Future<void> deleteResumption({
    required int? resumptionId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(resumptionRepositoryProvider)
        .deleteResumption(
          userContext: ref.watch(userContextProvider),
          resumptionId: resumptionId,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(context: context, content: 'Error occured in deleting');
      },
      (msg) {
        ref.invalidate(resumptionListProvider);
        showSnackBar(context: context, content: msg ?? 'Cannot delete');
      },
    );
  }

  Future<void> approveRejectResumption({
    required String note,
    required String requestId,
    required String approveRejectFlag,
    required BuildContext context,
  }) async {
    state = true;
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveResumptionRepositoryProvider);
    final result = await repo.approveRejectResumption(
      userContext: userContext,
      note: note,
      requestId: requestId,
      approveRejectFlag: approveRejectFlag,
    );
    state = false;

    return result.fold(
      (failure) => showSnackBar(context: context, content: failure.errMsg),
      (res) {
        ref.invalidate(approveResumptionListProvider);
        if (res == 'Approved Successfully' || res == 'Rejected Successfully') {
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
