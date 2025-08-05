import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/features/self_service/salary_advance/models/submit_salary_advance.dart';
import 'package:zeta_ess/features/self_service/salary_advance/providers/salaryAdvance_provider.dart';
import 'package:zeta_ess/features/self_service/salary_advance/repository/salary_advance_repository.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';
import '../../../approval_management/approve_salary_advance/controller/approve_salary_advance_controller.dart';
import '../../../approval_management/approve_salary_advance/repository/approve_salary_advance_repository.dart';
import '../models/salary_advance_details.dart';

final salaryAdvanceControllerProvider =
    NotifierProvider<SalaryAdvanceController, bool>(
      () => SalaryAdvanceController(),
    );

class SalaryAdvanceController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> submitSalaryAdvance({
    required SubmitSalaryAdvanceModel submitModel,
    required BuildContext context,
    required bool isEditMode,
  }) async {
    state = true;

    final res = await ref
        .read(salaryAdvanceRepositoryProvider)
        .submitSalaryAdvance(
          submitModel: submitModel,
          userContext: ref.read(userContextProvider),
        );
    state = false;

    res.fold(
      (error) {
        showCustomAlertBox(context, title: error.errMsg, type: AlertType.error);
      },
      (msg) {
        print(msg);
        ref.invalidate(salaryAdvanceListProvider);
        if (msg == '1') {
          Navigator.pop(context);
          showCustomAlertBox(
            context,
            title:
                isEditMode ? 'Updated successfully' : 'Submitted successfully',
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

  Future<void> deleteSalaryAdvance({
    required String? salaryAdvanceId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(salaryAdvanceRepositoryProvider)
        .deleteSalaryAdvance(
          userContext: ref.watch(userContextProvider),
          salaryAdvanceId: salaryAdvanceId,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(
          context: context,
          content: 'Error occured in deleting',
          color: AppTheme.errorColor,
        );
      },
      (deleted) {
        ref.invalidate(salaryAdvanceListProvider);
        showSnackBar(
          context: context,
          content: deleted ? 'Deleted successfully' : 'Cannot delete'.tr(),
        );
      },
    );
  }

  Future<void> approveAdvance({
    required BuildContext context,
    required String comment,
    required String requestId,
    required String approveAmount,
    required SalaryAdvanceDetailsModel salaryDetails,
  }) async {
    state = true;
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveSalaryAdvanceRepositoryProvider);

    final result = await repo.approveSalaryAdvance(
      userContext: userContext,
      comment: comment,
      requestId: requestId,
      salaryDetails: salaryDetails,
      approveAmount: approveAmount,
    );

    state = false;

    return result.fold(
      (failure) {
        showSnackBar(
          context: context,
          content: failure.errMsg,
          color: AppTheme.errorColor,
        );
      },
      (res) {
        ref.invalidate(approveSalaryAdvanceListProvider);

        print(res);

        // Translate response
        String responseMsg;
        switch (res) {
          case "True":
            responseMsg = ("Updated successfully!");
            break;
          case "1":
            responseMsg = ("Approved Successfully");
            break;
          case "-2":
            responseMsg =
                ("Could not approve. Salary advance allowance head is not mapped!");
            break;
          case "-3":
            responseMsg =
                ("Could not approve. Salary advance deduction head is not mapped!");
            break;
          case "-4":
          case "-5":
            responseMsg = ("Daily attendance exists on applied date!");
            break;
          case "-6":
            responseMsg = ("Timesheet exists on requested date!");
            break;
          case "-7":
            responseMsg = ("Month-end process days exist in the leave days!");
            break;
          case "Could not Approve.Trial payroll is executed for this employee.":
            responseMsg =
                ("Could not Approve. Trial payroll is executed for this employee.");
            break;
          default:
            responseMsg = "Something went wrong, please try again later!";
        }

        // Show response message
        showSnackBar(context: context, content: responseMsg);

        // Navigate back only if success
        if (res == "1" || res == "True") {
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> rejectAdvance({
    required BuildContext context,
    required String comment,
    required String requestId,
    required String approveAmount,
    required SalaryAdvanceDetailsModel salaryDetails,
  }) async {
    state = true;
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveSalaryAdvanceRepositoryProvider);

    final result = await repo.rejectSalaryAdvance(
      userContext: userContext,
      comment: comment,
      requestId: requestId,
      salaryDetails: salaryDetails,
      approveAmount: approveAmount,
    );

    state = false;

    return result.fold(
      (failure) {
        showSnackBar(
          context: context,
          content: failure.errMsg,
          color: AppTheme.errorColor,
        );
      },
      (res) {
        ref.invalidate(approveSalaryAdvanceListProvider);

        print(res);

        // Handle response
        String responseMsg;

        switch (res) {
          case "True":
            responseMsg = "Updated successfully!";
            break;
          case "1":
            responseMsg = "Rejected Successfully";
            break;
          case "-2":
            responseMsg =
                "Could not approve. Salary advance allowance head is not mapped!";
            break;
          case "-3":
            responseMsg =
                "Could not approve. Salary advance deduction head is not mapped!";
            break;
          case "-4":
          case "-5":
            responseMsg = "Daily attendance exists on applied date!";
            break;
          case "-6":
            responseMsg = "Timesheet exists on requested date!";
            break;
          case "-7":
            responseMsg = "Month-end process days exist in the leave days!";
            break;
          case "Could not Approve.Trial payroll is executed for this employee.":
            responseMsg =
                "Could not approve. Trial payroll is executed for this employee.";
            break;
          default:
            responseMsg = "Something went wrong, please try again later!";
        }

        showSnackBar(context: context, content: responseMsg);

        if (res == "1" || res == "True") {
          Navigator.pop(context);
        }
      },
    );
  }
}
