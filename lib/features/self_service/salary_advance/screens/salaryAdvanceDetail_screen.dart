import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/salary_advance/models/salary_advance_details.dart';

import '../../../../core/common/buttons/approveReject_buttons.dart';
import '../../../../core/common/common_text.dart';
import '../controller/salary_advance_controller.dart';
import '../providers/salaryAdvance_provider.dart';

class SalaryAdvanceDetailScreen extends ConsumerStatefulWidget {
  final bool? isLineManager;
  final bool showApproveAmount;
  final String? advanceId;
  const SalaryAdvanceDetailScreen({
    super.key,
    this.isLineManager,
    this.advanceId,
    this.showApproveAmount = false,
  });

  @override
  ConsumerState<SalaryAdvanceDetailScreen> createState() =>
      _SalaryAdvanceDetailScreenState();
}

class _SalaryAdvanceDetailScreenState
    extends ConsumerState<SalaryAdvanceDetailScreen> {
  final TextEditingController commentController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  SalaryAdvanceDetailsModel? salaryDetails;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(detailAppBarText.tr())),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: ref
              .watch(salaryAdvanceDetailsProvider(widget.advanceId))
              .when(
                data: (advance) {
                  salaryDetails = advance;
                  return ListView(
                    children: [
                      titleHeaderText('salary_advance_details'.tr()),

                      detailInfoRow(
                        title: 'employee_id'.tr(),
                        subTitle: advance.empId,
                      ),
                      detailInfoRow(
                        title: 'employee_name'.tr(),
                        subTitle: advance.name,
                      ),
                      detailInfoRow(
                        title: '${'requested'.tr()} ${'amount'.tr()}',
                        subTitle: advance.amount,
                      ),

                      if (widget.showApproveAmount)
                        detailInfoRow(
                          title: '${'approved'.tr()} ${'amount'.tr()}',
                          subTitle: advance.appAmount,
                        ),

                      detailInfoRow(
                        title: 'Month and year'.tr(),
                        subTitle: advance.dateFrom,
                      ),
                      detailInfoRow(
                        title: 'Payment mode'.tr(),
                        subTitle:
                            advance.iRqmode == '1'
                                ? 'With Payroll'
                                : 'Without Payroll',
                      ),
                      detailInfoRow(
                        title: 'note'.tr(),
                        subTitle: advance.note.isNotEmpty ? advance.note : '--',
                      ),

                      titleHeaderText("comment".tr()),
                      Text(
                        advance.appRejComment.isEmpty
                            ? advance.prevComment
                            : advance.appRejComment,
                      ),

                      if (widget.isLineManager ?? false) ...[
                        inputField(
                          hint: 'Approve amount'.tr(),
                          controller: amountController,
                          keyboardType: TextInputType.number,
                        ),
                        10.heightBox,
                        inputField(
                          hint: 'Approve/Reject Comment'.tr(),
                          minLines: 3,
                          controller: commentController,
                        ),
                      ],
                      100.heightBox,
                    ],
                  );
                },
                error: (error, _) => ErrorText(error: error.toString()),
                loading: () => Loader(),
              ),
        ),
      ),
      bottomSheet:
          widget.isLineManager ?? false
              ? SafeArea(
                child: ApproveRejectButtons(
                  onApprove: () {
                    if (amountController.text.isEmpty) {
                      showCustomAlertBox(
                        context,
                        title: 'Enter approved amount',
                        type: AlertType.error,
                      );
                      return;
                    }
                    if (double.parse(amountController.text.trim()) >
                        double.parse(salaryDetails?.amount ?? '0')) {
                      showCustomAlertBox(
                        context,
                        title:
                            'Approved amount should be less than or equal to Requested amount.',
                        type: AlertType.error,
                      );
                      return;
                    }
                    if (salaryDetails == null) {
                      showCustomAlertBox(
                        context,
                        title: 'No salary details found',
                        type: AlertType.error,
                      );
                      return;
                    }

                    ref
                        .read(salaryAdvanceControllerProvider.notifier)
                        .approveAdvance(
                          comment: commentController.text,
                          requestId: widget.advanceId ?? '0',
                          salaryDetails: salaryDetails!,
                          context: context,
                          approveAmount: amountController.text,
                        );
                  },
                  onReject: () {
                    if (commentController.text.isEmpty) {
                      showCustomAlertBox(
                        context,
                        title: 'Enter reject comment',
                        type: AlertType.error,
                      );
                      return;
                    }
                    if (commentController.text.length > 500) {
                      showCustomAlertBox(
                        context,
                        title: 'Maximum 500 characters allowed',
                        type: AlertType.error,
                      );
                      return;
                    }
                    if (salaryDetails == null) {
                      showCustomAlertBox(
                        context,
                        title: 'No salary details found',
                        type: AlertType.error,
                      );
                      return;
                    }
                    ref
                        .read(salaryAdvanceControllerProvider.notifier)
                        .rejectAdvance(
                          comment: commentController.text,
                          requestId: widget.advanceId ?? '0',
                          salaryDetails: salaryDetails!,
                          context: context,
                          approveAmount: amountController.text,
                        );
                  },
                ),
              )
              : const SizedBox.shrink(),
    );
  }
}
