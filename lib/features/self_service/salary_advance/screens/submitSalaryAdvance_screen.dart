import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/customDateTime_pickers/month_and_year_picker.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';
import 'package:zeta_ess/features/self_service/salary_advance/models/submit_salary_advance.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../core/common/common_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customElevatedButton_widget.dart';
import '../controller/salary_advance_controller.dart';
import '../models/salary_advance_details.dart';
import '../providers/salaryAdvance_provider.dart';

class SubmitSalaryAdvanceScreen extends ConsumerStatefulWidget {
  final String? advanceId;
  const SubmitSalaryAdvanceScreen({super.key, this.advanceId});

  @override
  ConsumerState<SubmitSalaryAdvanceScreen> createState() =>
      _SubmitSalaryAdvanceScreenState();
}

class _SubmitSalaryAdvanceScreenState
    extends ConsumerState<SubmitSalaryAdvanceScreen> {
  final monthYearController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  final withPayroll = StateProvider<bool>((ref) => false);
  bool isEditMode = false;
  bool hasPrefilled = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.advanceId != null;
  }

  void prefillFields(SalaryAdvanceDetailsModel? model) {
    if (hasPrefilled || model == null) return;

    monthYearController.text = convertMonthYearToMMYYYY(model.dateFrom);
    amountController.text = model.amount;
    noteController.text = model.note;
    Future.microtask(
      () => ref.read(withPayroll.notifier).state = model.iRqmode == '1',
    );

    hasPrefilled = true;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SalaryAdvanceDetailsModel>? details =
        isEditMode
            ? ref.watch(salaryAdvanceDetailsProvider(widget.advanceId))
            : null;

    final advance = details?.maybeWhen(data: (d) => d, orElse: () => null);
    if (advance != null) prefillFields(advance);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode
              ? '${'edit'.tr()} ${'salary_advance'.tr()}'
              : '${submitText.tr()} ${'salary_advance'.tr()}',
        ),
      ),
      body: SafeArea(
        child:
            details?.when(
              loading: () => const Loader(),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (_) => _buildForm(context, advance?.subDate),
            ) ??
            _buildForm(context, null),
      ),
      bottomSheet:
          ref.watch(salaryAdvanceControllerProvider)
              ? Loader()
              : SafeArea(
                child: Padding(
                  padding: AppPadding.screenBottomSheetPadding,
                  child: CustomElevatedButton(
                    onPressed: () {
                      if (monthYearController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        showCustomAlertBox(
                          context,
                          title: "pleaseFillRequiredFields".tr(),
                          type: AlertType.error,
                        );

                        return;
                      }
                      final user = ref.read(userContextProvider);
                      final submitModel = SubmitSalaryAdvanceModel(
                        suconn: user.companyConnection,
                        sucode: user.companyCode,
                        emcode: int.parse(user.empCode),
                        username: user.empName,
                        iSaid: int.parse(widget.advanceId ?? '0'),
                        monthyear: monthYearController.text,
                        reqdate: formatDate(DateTime.now()),
                        note: noteController.text,
                        amount: amountController.text,
                        url: user.baseUrl,
                        cocode: 91,
                        paymentMode: ref.watch(withPayroll) ? 1 : 2,
                        baseDirectory: '', //TODO give from locall
                      );
                      ref
                          .read(salaryAdvanceControllerProvider.notifier)
                          .submitSalaryAdvance(
                            submitModel: submitModel,
                            context: context,
                            isEditMode: isEditMode,
                          );
                    },
                    child: Text(
                      isEditMode ? 'Update' : '${submitText.tr()} ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildForm(BuildContext context, String? submittedDate) {
    return SingleChildScrollView(
      padding: AppPadding.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelText(
            submittedDate == null
                ? "${"submitting_date".tr()} ${formatDate(DateTime.now())}"
                : "${'submitted_date'.tr()} $submittedDate",
          ),
          labelText("request_month_and_year".tr(), isRequired: true),
          MonthYearPickerField(
            controller: monthYearController,
            label: "select_duration".tr(),
          ),
          labelText("amount".tr(), isRequired: true),
          inputField(
            hint: "enter_amount".tr(),
            controller: amountController,
            keyboardType: TextInputType.number,
          ),
          labelText("note".tr()),
          inputField(
            hint: "enter_your_note".tr(),
            minLines: 3,
            controller: noteController,
          ),
          labelText("payment_mode".tr()),
          Row(
            children: [
              radioButtonContainer(
                title: 'with_payroll'.tr(),
                isSelected: ref.watch(withPayroll) == true,
                value: 'with',
                onTap: () => ref.read(withPayroll.notifier).state = true,
              ),
              16.widthBox,
              radioButtonContainer(
                title: 'without_payroll'.tr(),
                isSelected: ref.watch(withPayroll) == false,
                value: 'without',
                onTap: () => ref.read(withPayroll.notifier).state = false,
              ),
            ],
          ),
          100.heightBox,
        ],
      ),
    );
  }

  @override
  void dispose() {
    monthYearController.dispose();
    amountController.dispose();
    noteController.dispose();
    hasPrefilled = false;
    super.dispose();
  }
}

//TODO only submit
// class SubmitSalaryAdvanceScreen extends ConsumerStatefulWidget {
//   const SubmitSalaryAdvanceScreen({super.key});
//
//   @override
//   ConsumerState<SubmitSalaryAdvanceScreen> createState() =>
//       _SubmitSalaryAdvanceScreenState();
// }
//
// class _SubmitSalaryAdvanceScreenState
//     extends ConsumerState<SubmitSalaryAdvanceScreen> {
//   StateProvider<bool> withPayroll = StateProvider<bool>((ref) => false);
//   final TextEditingController monthYearController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
//   final TextEditingController noteController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${submitText.tr()} ${"salary_advance".tr()}'),
//       ),
//       body: SingleChildScrollView(
//         padding: AppPadding.screenPadding,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             labelText(
//               "${"submitting_date".tr()} ${formatDate(DateTime.now())}",
//             ),
//             labelText("request_month_and_year".tr(), isRequired: true),
//             MonthYearPickerField(
//               controller: monthYearController,
//               label: "select_duration".tr(),
//             ),
//
//             labelText("amount".tr(), isRequired: true),
//             inputField(hint: "enter_amount".tr(), controller: amountController),
//
//             labelText("note".tr()),
//             inputField(
//               hint: "enter_your_note".tr(),
//               minLines: 3,
//               controller: noteController,
//             ),
//
//             labelText("payment_mode".tr()),
//             Row(
//               children: [
//                 radioButtonContainer(
//                   title: 'with_payroll'.tr(),
//                   isSelected: ref.watch(withPayroll) == true,
//                   value: 'with',
//                   onTap: () {
//                     ref.read(withPayroll.notifier).state = true;
//                   },
//                 ),
//                 SizedBox(width: 16),
//                 radioButtonContainer(
//                   title: 'without_payroll'.tr(),
//                   isSelected: ref.watch(withPayroll) == false,
//                   value: 'without',
//                   onTap: () {
//                     ref.read(withPayroll.notifier).state = false;
//                   },
//                 ),
//               ],
//             ),
//
//             50.heightBox,
//           ],
//         ),
//       ),
//       bottomSheet: Padding(
//         padding: AppPadding.screenBottomSheetPadding,
//         child: CustomElevatedButton(
//           onPressed: () {
//             if (monthYearController.text.isEmpty ||
//                 amountController.text.isEmpty) {
//               showSnackBar(
//                 content: "pleaseFillRequiredFields",
//                 context: context,
//                 color: AppTheme.errorColor,
//               );
//               return;
//             }
//             final user = ref.read(userContextProvider);
//             final submitModel = SubmitSalaryAdvanceModel(
//               suconn: user.companyConnection,
//               emcode: int.parse(user.empCode),
//               username: user.empName,
//               iSaid: 0, // TODO advance IDD
//               monthyear: monthYearController.text,
//               reqdate: formatDate(DateTime.now()),
//               note: noteController.text,
//               amount: amountController.text,
//               url: user.baseUrl,
//               cocode: 91,
//               paymentMode: ref.watch(withPayroll) ? 1 : 2,
//               baseDirectory: '', //TODO give from locall
//             );
//             ref
//                 .read(salaryAdvanceControllerProvider.notifier)
//                 .submitSalaryAdvance(
//                   submitModel: submitModel,
//                   context: context,
//                 );
//           },
//           child: Text(
//             '${submitText.tr()} ',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     monthYearController.dispose();
//   }
// }
