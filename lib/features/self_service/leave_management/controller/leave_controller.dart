import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/no_server_screen.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/approval_management/approveLeave_management/repository/approve_leave_repository.dart';
import 'package:zeta_ess/features/self_service/leave_management/repository/leave_repository.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../core/common/widgets/customFilePicker_widget.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';
import '../../../approval_management/approveLeave_management/controller/approve_leave_controller.dart';
import '../../resumption_request/controller/resumption_controller.dart';
import '../../resumption_request/models/submit_resumption_model.dart';
import '../models/leaveSubmission_model.dart';
import '../models/leave_model.dart';
import '../providers/leave_providers.dart';
import 'old_hrms_configuration_stuffs.dart';

final leaveControllerProvider = NotifierProvider<LeaveController, bool>(
  () => LeaveController(),
);

class LeaveController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> cancelLeave({
    required String lsslno,
    required String dateFrom,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(leaveRepositoryProvider)
        .cancelLeave(
          userContext: ref.watch(userContextProvider),
          lsslno: lsslno,
          dateFrom: dateFrom,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(context: context, content: 'Error occured in cancelling');
      },
      (response) {
        if (response.toString().contains('submitted successfully')) {
          Navigator.pop(context);

          showSnackBar(
            context: context,
            content: 'Leave cancellation submitted',
          );
        } else {
          showCustomAlertBox(
            context,
            title: response.toString(),
            type: AlertType.error,
            onPrimaryPressed: () => Navigator.pop(context),
          );
        }
        ref.invalidate(submittedLeaveListProvider);
      },
    );
  }

  Future<void> deleteLeave({
    required int leaveId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(leaveRepositoryProvider)
        .deleteLeave(
          userContext: ref.watch(userContextProvider),
          leaveId: leaveId,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(context: context, content: 'Error occured in deleting');
      },
      (deleted) {
        ref.invalidate(
          submittedLeaveListProvider,
        ); //TODO is this correct to referesh after deleating? //
        showSnackBar(
          context: context,
          content: deleted ? 'Deleted successfully' : 'Cannot delete'.tr(),
        );
      },
    );
  }

  Future<void> getLeaveDays({
    required String dateFrom,
    required String dateTo,
    required String leaveCode,
  }) async {
    state = true;

    final result = await ref
        .read(leaveRepositoryProvider)
        .getTotalLeaveDays(
          userContext: ref.read(userContextProvider),
          dateFrom: dateFrom,
          dateTo: dateTo,
          leaveCode: leaveCode,
        );

    result.fold(
      (l) {
        ref.read(totalLeaveDaysStateProvider.notifier).state = 'Error';
      },
      (r) {
        LeaveConfigurationController().setTotalLeaves(r);
        ref.read(totalLeaveDaysStateProvider.notifier).state = r;
      },
    );

    state = false;
  }

  Future<void> approveLeave({
    required String comment,
    required LeaveModel leaveDetails,
    required BuildContext context,
  }) async {
    state = true;
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveLeaveRepositoryProvider);

    final result = await repo.approveLeave(
      userContext: userContext,
      comment: comment,
      leaveDetails: leaveDetails,
    );

    state = false;

    result.fold(
      (err) => showSnackBar(content: err.toString(), context: context),
      (res) {
        ref.invalidate(approveLeaveListProvider);

        onRight(res ?? 'Something wrong', context);
      },
    );
  }

  Future<void> rejectLeave({
    required String comment,
    required LeaveModel leaveDetails,
    required BuildContext context,
  }) async {
    state = true;
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveLeaveRepositoryProvider);

    final result = await repo.rejectLeave(
      userContext: userContext,
      comment: comment,
      leaveDetails: leaveDetails,
    );

    state = false;

    result.fold(
      (err) => showSnackBar(context: context, content: err.toString()),
      (res) {
        ref.invalidate(approveLeaveListProvider);
        onRight(res ?? 'Something wrong', context);
      },
    );
  }

  void onRight(String response, BuildContext context) {
    String responseMsg;

    switch (response) {
      case "1":
        responseMsg = ("Approved Successfully");
        break;
      case "true":
        responseMsg = ("Rejected Successfully");
        break;
      case "-2":
        responseMsg = ("Resumption entry is pending for some of leave!");
        break;
      case "-3":
        responseMsg =
            ("Could not save , trial payroll executed for some of the requested days!");
        break;
      case "-4":
      case "-5":
        responseMsg = ("Daily attendance exist on applied date!");
        break;
      case "-6":
        responseMsg = ("Timesheet exist on requested date!");
        break;
      case "-7":
        responseMsg = ("Month end process days exist in the leave days!");
        break;
      default:
        responseMsg =
            response.isNotEmpty
                ? response
                : ("Something went wrong, please try again later!");
    }
    if (response == "1" || response == "true") {
      Navigator.pop(context);
    }
    showSnackBar(content: responseMsg, context: context);
  }
}

class LeaveTypesNotifier
    extends AutoDisposeAsyncNotifier<List<LeaveTypeModel>> {
  @override
  FutureOr<List<LeaveTypeModel>> build() async {
    final repo = ref.read(leaveRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getLeaveTypes(userContext: userContext);
    return result.fold((l) => throw l.errMsg, (r) => r);
  }
}

class SubmitLeaveNotifier extends AutoDisposeAsyncNotifier<String?> {
  @override
  FutureOr<String?> build() => null;

  Future<String?> submitLeave({
    required LeaveSubmissionRequest leaveSubmitModel,
    required BuildContext context,
    required SubmitResumptionModel? submitResumptionModel,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(leaveRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    // Step 1: Call First API
    final firstResult = await repo.submitLeaveFirstApi(
      leaveCode: leaveSubmitModel.leaveCode,
      fromDate: leaveSubmitModel.fromDate,
      toDate: leaveSubmitModel.toDate,
      userContext: userContext,
    );
    final first = firstResult.fold((l) {
      NavigationService.navigateToScreen(
        context: context,
        screen: const NoServer(),
      );
      return null;
    }, (r) => r);

    if (first == null) return null;

    // Step 2: Final Leave Submission
    final finalResult = await repo.submitLeave(leaveSubmitModel, userContext);

    return finalResult.fold(
      (l) {
        NavigationService.navigateToScreen(
          context: context,
          screen: const NoServer(),
        );
        state = AsyncError(l, StackTrace.current);

        return null;
      },
      (response) {
        if (response != null) {
          if (response == "Leave Submitted Successfully" ||
              response == 'Leave Updated Successfully') {
            //TODO this is to submit the resumption request if data changes
            if (submitResumptionModel != null) {
              ref
                  .read(resumptionControllerProvider.notifier)
                  .submitResumptionLeave(
                    submitResumptionModel: submitResumptionModel,
                    context: context,
                    isFromLeaveSubmit: true,
                  );
            } else {
              Navigator.pop(context);
              showCustomAlertBox(
                context,
                title: response,
                type: AlertType.success,
                onPrimaryPressed: () => Navigator.pop(context),
              );
              leaveController.setData([]);
              ref.read(fileUploadProvider.notifier).clearFile();
            }
          } else {
            showCustomAlertBox(
              context,
              title: response.toString(),
              type: AlertType.warning,
            );
          }
          ref.invalidate(submittedLeaveListProvider);
        }
        state = AsyncData(response);

        return response;
      },
    );
  }
}
