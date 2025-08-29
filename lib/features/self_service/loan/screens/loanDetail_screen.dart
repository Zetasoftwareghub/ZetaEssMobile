import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/common/widgets/attachment_viewer.dart';
import 'package:zeta_ess/core/common/widgets/customDatePicker_widget.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/approval_management/approve_loan/models/approve_loan_model.dart';
import 'package:zeta_ess/features/self_service/loan/models/loan_list_model.dart';

import '../../../../core/common/buttons/approveReject_buttons.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../approval_management/approve_loan/controller/approve_loan_controller.dart';
import '../providers/loan_providers.dart';

class LoanDetailScreen extends ConsumerStatefulWidget {
  final bool? isLineManager;
  final String loanId;
  final LoanListModel? loanListModel;
  final String? requestEmpName;

  const LoanDetailScreen({
    super.key,
    this.isLineManager,
    required this.loanId,
    this.loanListModel,
    this.requestEmpName,
  });

  @override
  ConsumerState<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends ConsumerState<LoanDetailScreen> {
  final TextEditingController commentController = TextEditingController();
  final TextEditingController approveAmountController = TextEditingController();

  final selectedDateProvider = StateProvider<String?>((ref) => null);

  @override
  Widget build(BuildContext context) {
    print(widget.loanId);
    print('widget.loanId23');
    final loanDetailsAsync = ref.watch(loanDetailsProvider(widget.loanId));
    return Scaffold(
      appBar: AppBar(title: Text('details'.tr())),
      body: loanDetailsAsync.when(
        loading: () => Loader(),
        error: (err, _) => ErrorText(error: err.toString()),
        data: (loan) {
          approveAmountController.text = loan.loanAmount.toString();
          return SafeArea(
            child: Padding(
              padding: AppPadding.screenPadding,
              child: ListView(
                children: [
                  titleHeaderText('employee_details'.tr()),
                  detailInfoRow(
                    title: 'employee_id'.tr(),
                    subTitle: loan.employeeCode.toString(),
                  ),
                  detailInfoRow(
                    title: 'employee_name'.tr(),
                    subTitle: widget.loanListModel?.emname,
                  ), // Replace if available

                  titleHeaderText("submitted_details".tr()),
                  detailInfoRow(
                    title: 'submitted_date'.tr(),
                    subTitle: loan.submittedDate,
                  ),
                  detailInfoRow(
                    title: 'loan_type'.tr(),
                    subTitle: widget.loanListModel?.loanType,
                  ), // Replace if available
                  detailInfoRow(
                    title: "repayment_period".tr(),
                    subTitle: '${loan.approvedMonths} Months',
                  ),
                  detailInfoRow(
                    title: 'amount'.tr(),
                    subTitle: '${loan.loanAmount}',
                  ),

                  detailInfoRow(
                    title: 'loan_start_date'.tr(),
                    subTitle: loan.repaymentStartDate,
                  ),

                  detailInfoRow(
                    title: 'status'.tr(),
                    subTitle: widget.loanListModel?.loanStatus ?? 'N/A',
                  ),
                  detailInfoRow(title: "note".tr(), subTitle: loan.note ?? '—'),
                  detailInfoRow(
                    title: "Approved Date".tr(),
                    subTitle: loan.approvedDate ?? '—',
                  ),
                  detailInfoRow(
                    title: "Approved amount".tr(),
                    subTitle: loan.approvedAmount.toString() ?? '—',
                  ),

                  titleHeaderText("comment".tr()),
                  Text(loan.approverNote),
                  titleHeaderText("attachments".tr()),
                  AttachmentWidget(
                    attachmentUrl:
                        loan.filePath == null ||
                                (loan.filePath?.isEmpty ?? false)
                            ? null
                            : '${ref.watch(userContextProvider).userBaseUrl}/${loan.filePath}',
                  ),
                  15.heightBox,
                  if (widget.isLineManager ?? false) ...[
                    CustomDateField(
                      hintText: 'Approve date',
                      initialDate:
                          ref.watch(selectedDateProvider) ??
                          formatDate(DateTime.now()),
                      onDateSelected: (date) {
                        ref.read(selectedDateProvider.notifier).state = date;
                      },
                    ),
                    10.heightBox,
                    inputField(
                      hint: 'Approve amount',
                      controller: approveAmountController,
                      keyboardType: TextInputType.number,
                    ),
                    10.heightBox,

                    inputField(
                      hint: 'Enter approve/reject comment',
                      controller: commentController,
                    ),
                  ],
                  80.heightBox,
                ],
              ),
            ),
          );
        },
      ),
      bottomSheet:
          widget.isLineManager ?? false
              ? SafeArea(
                child: ApproveRejectButtons(
                  onApprove: () {
                    if (approveAmountController.text.isEmpty ||
                        ref.watch(selectedDateProvider) == null) {
                      showCustomAlertBox(
                        context,
                        title: 'Please give approve date and amount',
                      );
                      return;
                    }
                    final loan = loanDetailsAsync.value;
                    final userContext = ref.watch(userContextProvider);
                    final approveLoanModel = ApproveLoanModel(
                      suconn: userContext.companyConnection,
                      aprDate:
                          ref.watch(selectedDateProvider) ??
                          formatDate(DateTime.now()),
                      reqDate: loan?.repaymentStartDate,
                      amount: double.parse(approveAmountController.text),
                      username: userContext.empName,
                      lqslno: int.parse(loan?.loanSerialNo.toString() ?? '0'),
                      reqemcode: loan?.requestEmployeeCode,
                      emcode: int.parse(userContext.empCode),
                      comment: commentController.text,
                      aprflg: 'A',
                    );
                    ref
                        .read(approveLoanControllerProvider.notifier)
                        .approveRejectLoan(
                          approveLoanModel: approveLoanModel,
                          context: context,
                        );
                  },
                  onReject: () {
                    final loan = loanDetailsAsync.value;
                    final userContext = ref.watch(userContextProvider);

                    final approveLoanModel = ApproveLoanModel(
                      suconn: userContext.companyConnection,
                      aprDate: formatDate(DateTime.now()),
                      reqDate: loan?.repaymentStartDate,
                      amount:
                          double.tryParse(approveAmountController.text) ?? 0,
                      username: userContext.empName,
                      lqslno: int.parse(loan?.loanSerialNo.toString() ?? '0'),
                      reqemcode: loan?.requestEmployeeCode,
                      emcode: int.parse(userContext.empCode),
                      comment: commentController.text,
                      aprflg: 'R',
                    );

                    ref
                        .read(approveLoanControllerProvider.notifier)
                        .approveRejectLoan(
                          approveLoanModel: approveLoanModel,
                          context: context,
                        );
                  },
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}

//
// class LoanDetailScreen extends StatelessWidget {
//   final bool? isLineManager;
//   final String loanId;
//   const LoanDetailScreen({super.key, this.isLineManager, required this.loanId});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(detailAppBarText.tr())),
//
//       body: SafeArea(
//         child: Padding(
//           padding: AppPadding.screenPadding,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               titleHeaderText('employee_details'.tr()),
//               detailInfoRow(title: 'employee_id'.tr(), subTitle: 'EMP1234'),
//               detailInfoRow(
//                 title: 'employee_name'.tr(),
//                 subTitle: 'Ananthu Krishna',
//               ),
//
//               titleHeaderText("submitted_details".tr()),
//               detailInfoRow(
//                 title: 'submitted_date'.tr(),
//                 subTitle: '10/10/2025',
//               ),
//               detailInfoRow(
//                 title: 'loan_type'.tr(),
//                 subTitle: 'Education Loan',
//               ),
//               detailInfoRow(title: 'loan_tenure'.tr(), subTitle: '10 Years'),
//               detailInfoRow(title: 'loan_interest_rate'.tr(), subTitle: '10%'),
//               detailInfoRow(
//                 title: 'loan_start_date'.tr(),
//                 subTitle: '2025-01-01',
//               ),
//
//               detailInfoRow(
//                 title: 'status'.tr(),
//                 subTitle: 'Pending to approve',
//               ),
//               detailInfoRow(
//                 title: "note".tr(),
//                 belowValue:
//                     "dLorem Ipsum is simply dummy  text of the printing and  dhhtypesetting industry.",
//               ),
//               titleHeaderText("attachments".tr()),
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: 4.h),
//                 child: Text(
//                   '* No Attachments',
//                   style: TextStyle(color: Colors.red, fontSize: 14.sp),
//                 ),
//               ),
//               30.heightBox,
//             ],
//           ),
//         ),
//       ),
//       bottomSheet:
//           isLineManager ?? false
//               ? SafeArea(
//                 child: ApproveRejectButtons(onApprove: () {}, onReject: () {}),
//               )
//               : const SizedBox.shrink(),
//     );
//   }
// }
