import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/common/common_text.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/customDateTime_pickers/month_and_year_picker.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/expense_claim/controller/expenseClaim_controller.dart';
import 'package:zeta_ess/features/self_service/expense_claim/models/expense_claim_model.dart';
import '../../../../core/common/buttons/approveReject_buttons.dart';
import '../../../../core/services/validator_services.dart';
import '../providers/expense_claim_providers.dart';

class ExpenseClaimDetailsScreen extends ConsumerStatefulWidget {
  final int? expenseClaimId;
  final bool? isLineManager;
  final bool isApprovedTab;

  const ExpenseClaimDetailsScreen({
    super.key,
    this.isLineManager,
    this.isApprovedTab = false,
    required this.expenseClaimId,
  });

  @override
  ConsumerState<ExpenseClaimDetailsScreen> createState() =>
      _ExpenseClaimDetailsScreenState();
}

class _ExpenseClaimDetailsScreenState
    extends ConsumerState<ExpenseClaimDetailsScreen> {
  final TextEditingController approveRejectMonthYear = TextEditingController();
  final TextEditingController approveAmountController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ExpenseClaimModel? expenseClaimModel;
  @override
  Widget build(BuildContext context) {
    final details = ref.watch(
      expenseClaimDetailsProvider(widget.expenseClaimId ?? 0),
    );

    return Scaffold(
      appBar: AppBar(title: Text('expense_claim'.tr())),
      body:
          ref.watch(expenseClaimControllerProvider)
              ? Loader()
              : SafeArea(
                child: Padding(
                  padding: AppPadding.screenPadding,
                  child: SingleChildScrollView(
                    child: details.when(
                      data: (claimDetail) {
                        expenseClaimModel = claimDetail;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleHeaderText('employee_details'),
                            detailInfoRow(
                              title: 'employee_id',
                              subTitle: claimDetail.employeeID,
                            ),
                            detailInfoRow(
                              title: 'employee_name',
                              subTitle: claimDetail.employeeName,
                            ),
                            20.heightBox,
                            titleHeaderText('submitted_details'.tr()),
                            Divider(height: 24.h),
                            detailInfoRow(
                              title: 'requested_date',
                              subTitle: claimDetail.reqdate,
                            ),
                            detailInfoRow(
                              title: 'requested_month_and_year',
                              subTitle: claimDetail.monthyear,
                            ),
                            // detailInfoRow(
                            //   title: 'approved_month_and_year'.tr(),
                            //   subTitle: claimDetail.approveMonthYear,
                            // ),
                            detailInfoRow(
                              title: 'Expense claim',
                              subTitle: claimDetail.expenseClaimName,
                            ),
                            detailInfoRow(
                              title: 'requested_amount',
                              subTitle: claimDetail.amount,
                            ),
                            if (widget.isApprovedTab)
                              detailInfoRow(
                                title: 'approved_amount',
                                subTitle: claimDetail.approveAmount,
                              ),
                            detailInfoRow(
                              title: "note",
                              subTitle:
                                  claimDetail.note == 'null'
                                      ? ''
                                      : claimDetail.note,
                            ),

                            if (claimDetail.comment?.isNotEmpty ?? false) ...[
                              titleHeaderText('comment'.tr()),
                              Text(claimDetail.comment ?? ''),
                            ],
                            10.heightBox,
                            if (widget.isLineManager ?? false) ...[
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    MonthYearPickerField(
                                      controller: approveRejectMonthYear,
                                      label:
                                          'Approve/Reject month and year'.tr(),
                                    ),
                                    10.heightBox,

                                    inputField(
                                      hint: 'Approve Amount'.tr(),
                                      controller: approveAmountController,
                                      onChanged: (amount) {
                                        ValidatorServices.validateApproveAmount(
                                          context: context,
                                          controller: approveAmountController,
                                          requestedAmount:
                                              claimDetail.approveAmount ??
                                              claimDetail.amount,
                                        );
                                      },

                                      keyboardType: TextInputType.number,
                                      isRequired: true,
                                    ),
                                    10.heightBox,
                                    inputField(
                                      hint: 'Approve/Reject Comment'.tr(),
                                      controller: commentController,
                                      isRequired: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            100.heightBox,
                          ],
                        );
                      },
                      error:
                          (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                      loading: () => Loader(),
                    ),
                  ),
                ),
              ),
      bottomSheet:
          ref.watch(expenseClaimControllerProvider)
              ? Loader()
              : widget.isLineManager ?? false
              ? SafeArea(
                child: ApproveRejectButtons(
                  onApprove: () {
                    final isValid = ValidatorServices.validateApproveAmount(
                      context: context,
                      controller: approveAmountController,
                      requestedAmount: expenseClaimModel?.amount ?? '0',
                    );

                    if (!isValid) return;

                    if (approveRejectMonthYear.text.isEmpty ||
                        approveAmountController.text.isEmpty) {
                      showCustomAlertBox(
                        context,
                        title: 'Please give approve date and amount',
                        type: AlertType.error,
                      );

                      return;
                    }
                    if (approveRejectMonthYear.text.isNotEmpty ||
                        _formKey.currentState!.validate()) {
                      if (expenseClaimModel != null) {
                        ref
                            .read(expenseClaimControllerProvider.notifier)
                            .approveExpenseClaim(
                              requestId:
                                  expenseClaimModel?.expenseClaimId
                                      .toString() ??
                                  '0',
                              context: context,
                              approveAmount: approveAmountController.text,
                              comment: commentController.text,
                              approveMonthYear: approveRejectMonthYear.text,
                              expenseClaim: expenseClaimModel!,
                            );
                      }
                    } else {
                      showCustomAlertBox(
                        context,
                        title: requiredFieldsText.tr(),
                        type: AlertType.error,
                      );
                      return;
                    }
                  },
                  onReject: () {
                    /*  onReject: () {
                        ValidatorServices.validateCommentAndShowAlert(
                          context: context,
                          controller: commentController,
                        );
                    if (isInvalid) return; */

                    if (expenseClaimModel != null) {
                      ref
                          .read(expenseClaimControllerProvider.notifier)
                          .rejectExpenseClaim(
                            context: context,
                            comment: commentController.text,
                            expenseClaim: expenseClaimModel!,
                          );
                    }
                  },
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    approveRejectMonthYear.dispose();
    approveAmountController.dispose();
    commentController.dispose();
  }
}
