import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import '../providers/expense_claim_providers.dart';

class ExpenseClaimDetailsScreen extends ConsumerStatefulWidget {
  final int? expenseClaimId;
  final bool? isLineManager;

  const ExpenseClaimDetailsScreen({
    super.key,
    this.isLineManager,
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
    print(widget.expenseClaimId);
    print('widget.expenseClaimId');
    final details = ref.watch(
      expenseClaimDetailsProvider(widget.expenseClaimId ?? 0),
    );

    return Scaffold(
      appBar: AppBar(title: Text('expense_claim'.tr())),
      body: SafeArea(
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
                    detailInfoRow(
                      title: 'approved_month_and_year'.tr(),
                      subTitle: claimDetail.approveMonthYear,
                    ),
                    detailInfoRow(
                      title: 'Approve Expense claim',
                      subTitle: claimDetail.expenseClaimName,
                    ),
                    detailInfoRow(
                      title: 'requested_amount',
                      subTitle: claimDetail.amount,
                    ),
                    detailInfoRow(
                      title: 'approved_amount',
                      subTitle: claimDetail.approveAmount,
                    ),
                    detailInfoRow(title: "note", subTitle: claimDetail.note),

                    titleHeaderText('comment'.tr()),
                    Text(claimDetail.comment ?? ''),
                    10.heightBox,
                    if (widget.isLineManager ?? false) ...[
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            MonthYearPickerField(
                              controller: approveRejectMonthYear,
                              label: 'Approve/Reject month and year'.tr(),
                            ),
                            10.heightBox,

                            inputField(
                              hint: 'Approve Amount'.tr(),
                              controller: approveAmountController,
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
                    80.heightBox,
                  ],
                );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => Loader(),
            ),
          ),
        ),
      ),
      bottomSheet:
          widget.isLineManager ?? false
              ? SafeArea(
                child: ApproveRejectButtons(
                  onApprove: () {
                    if (approveRejectMonthYear.text.isEmpty) {
                      showSnackBar(
                        context: context,
                        content: 'Select month and year',
                        color: AppTheme.errorColor,
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
                      showSnackBar(
                        context: context,
                        content: requiredFieldsText,
                        color: AppTheme.errorColor,
                      );
                    }
                  },
                  onReject: () {
                    if (commentController.text.isEmpty) {
                      showSnackBar(
                        context: context,
                        content: 'Give reject comment',
                        color: AppTheme.errorColor,
                      );
                      return;
                    }
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
