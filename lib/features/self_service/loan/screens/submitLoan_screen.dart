import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/loan/models/loan_details_model.dart';

import '../../../../core/common/common_text.dart';
import '../../../../core/common/common_ui_stuffs.dart';
import '../../../../core/common/widgets/customDatePicker_widget.dart';
import '../../../../core/common/widgets/customDropDown_widget.dart';
import '../../../../core/common/widgets/customFilePicker_widget.dart';
import '../controller/loan_controller.dart';
import '../models/loan_submit_model.dart';
import '../models/loan_type_model.dart';
import '../providers/loan_providers.dart';

class SubmitLoanScreen extends ConsumerStatefulWidget {
  final String? loanId;
  const SubmitLoanScreen({super.key, this.loanId});

  @override
  ConsumerState<SubmitLoanScreen> createState() => _SubmitLoanScreenState();
}

class _SubmitLoanScreenState extends ConsumerState<SubmitLoanScreen> {
  final amountController = TextEditingController();
  final periodController = TextEditingController();
  final noteController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? reqDate;
  String? deductionDate;

  final selectedLoanType = StateProvider<LoanTypeModel?>((ref) => null);
  bool isEditMode = false;
  bool hasPrefilled = false;

  int? loanTypeID;
  String? editFileUrl;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.loanId != null;
  }

  void prefillFields(LoanDetailModel? model) {
    print(model?.loanAmount);
    print('model.loanAmount');
    if (hasPrefilled || model == null) return;
    periodController.text = model.approvedMonths.toString();
    amountController.text = model.loanAmount.toString();
    noteController.text = model.note;
    deductionDate = model.repaymentStartDate;

    //TODO need this global or not? year first concerde
    reqDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateFormat('yyyy/MM/dd').parse(model.submittedDate));
    loanTypeID = model.LoanTypeCode;
    editFileUrl =
        '${ref.watch(userContextProvider).userBaseUrl}/${model.filePath}';
    // Future.microtask(
    //       () => ref.read(withPayroll.notifier).state = model.iRqmode == '1',
    // );

    hasPrefilled = true;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<LoanDetailModel>? details =
        isEditMode
            ? ref.watch(loanDetailsProvider(widget.loanId ?? '0'))
            : null;

    final loan = details?.maybeWhen(data: (d) => d, orElse: () => null);
    if (loan != null) prefillFields(loan);

    final isLoading = ref.watch(loanControllerProvider);
    final loanTypeAsync = ref.watch(loanTypeListProvider);
    final loanType = ref.watch(selectedLoanType);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode
              ? '${'Edit'.tr()} ${"loan".tr()}'
              : '${submitText.tr()} ${"loan".tr()}',
        ),
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screenPadding,
        child: Form(
          key: _formKey,
          child:
              isLoading
                  ? const Loader()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      labelText("requested_date".tr(), isRequired: true),
                      CustomDateField(
                        hintText: "select_date".tr(),
                        initialDate: reqDate,
                        onDateSelected:
                            (date) => setState(() => reqDate = date),
                      ),

                      labelText("loan_type".tr(), isRequired: true),
                      loanTypeAsync.when(
                        data: (loanTypes) {
                          if (loanTypeID != null &&
                              ref.watch(selectedLoanType) == null) {
                            Future.microtask(() {
                              final type = loanTypes.firstWhere(
                                (t) => t.typeCode == loanTypeID.toString(),
                                orElse: () => loanTypes.first,
                              );
                              ref.read(selectedLoanType.notifier).state = type;
                            });
                          }
                          return CustomDropdown<LoanTypeModel>(
                            value: loanType,
                            items:
                                loanTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.typeName),
                                  );
                                }).toList(),
                            onChanged:
                                (type) =>
                                    ref.read(selectedLoanType.notifier).state =
                                        type,
                            hintText: "select_type".tr(),
                          );
                        },
                        loading: () => const Loader(),
                        error: (err, _) => ErrorText(error: err.toString()),
                      ),

                      labelText("requested_amount".tr(), isRequired: true),
                      inputField(
                        hint: "enter_amount".tr(),
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        isRequired: true,
                      ),

                      labelText(
                        "repayment_period".tr() + ' (Months)'.tr(),
                        isRequired: true,
                      ),
                      inputField(
                        hint: "Enter Repayment Period",
                        controller: periodController,
                        keyboardType: TextInputType.number,
                        isRequired: true,
                      ),

                      labelText("deduction_start_date".tr(), isRequired: true),
                      CustomDateField(
                        hintText: "select_date".tr(),
                        initialDate: reqDate,

                        notBeforeInitialDate: true,
                        onDateSelected:
                            (date) => setState(() => deductionDate = date),
                      ),

                      labelText("note".tr()),
                      inputField(
                        hint: "enter_your_note".tr(),
                        minLines: 3,
                        controller: noteController,
                      ),

                      16.heightBox,
                      FileUploadButton(editFileUrl: editFileUrl),
                      50.heightBox,
                    ],
                  ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: AppPadding.screenBottomSheetPadding,
          child: CustomElevatedButton(
            onPressed: () async {
              print(amountController.text);
              print('amountController.text');
              final fileData = ref.read(fileUploadProvider).value;
              final userContext = ref.watch(userContextProvider);

              if (!_formKey.currentState!.validate()) {
                return;
              }
              if (deductionDate == null && reqDate != null) {
                showCustomAlertBox(
                  context,
                  title: 'Please verify the deduction start date',
                  content:
                      'A default date is pre-filled. Kindly review and confirm it is correct.',
                  type: AlertType.error,
                );
                return;
              }
              if (reqDate == null ||
                  deductionDate == null ||
                  loanType == null) {
                showCustomAlertBox(
                  context,
                  title: 'Please fill all required fields',
                  type: AlertType.error,
                );
                return;
              }

              final model = LoanSubmitRequestModel(
                suconn: userContext.companyConnection,
                emcode: int.parse(userContext.empCode),
                lntype: int.parse(loanType.typeCode),
                note: noteController.text,
                amount: amountController.text,
                reqdate: reqDate,
                username: userContext.empName,
                paymentperiod: int.tryParse(periodController.text) ?? 0,
                deductionstartdate: deductionDate,
                mediafile: fileData?.base64,
                mediaExtension: fileData?.extension,
                loid: int.tryParse(widget.loanId ?? '0') ?? 0,
                baseDirectory: userContext.userBaseUrl,
              );

              await ref
                  .read(loanControllerProvider.notifier)
                  .submitLoan(submitModel: model, context: context);
            },
            child: Text(
              isEditMode ? updateText.tr() : submitText.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    periodController.dispose();
    noteController.dispose();
    super.dispose();
  }
}

//
// class SubmitLoanScreen extends ConsumerStatefulWidget {
//   const SubmitLoanScreen({super.key});
//
//   @override
//   ConsumerState<SubmitLoanScreen> createState() => _SubmitLoanScreenState();
// }
//
// class _SubmitLoanScreenState extends ConsumerState<SubmitLoanScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final loanTypeAsync = ref.watch(loanTypeListProvider);
//
//     return Scaffold(
//       appBar: AppBar(title: Text('${submitText.tr()} ${"loan".tr()}')),
//       body: SingleChildScrollView(
//         padding: AppPadding.screenPadding,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             labelText("requested_date".tr(), isRequired: true),
//             CustomDateField(hintText: "select_date".tr(),onDateSelected: (),),
//             labelText("loan_type".tr(), isRequired: true),
//             loanTypeAsync.when(
//               data:
//                   (loanTypes) => CustomDropdown<LoanTypeModel>(
//                     items:
//                         loanTypes.map((type) {
//                           return DropdownMenuItem<LoanTypeModel>(
//                             value: type,
//                             child: Text(type.typeName),
//                           );
//                         }).toList(),
//                     onChanged: (v) {},
//                     hintText: "select_type",
//                   ),
//               error: (error, stackTrace) => ErrorText(error: error.toString()),
//               loading: () => Loader(),
//             ),
//
//             labelText("requested_amount".tr(), isRequired: true),
//             inputField(hint: "enter_amount".tr(),controller: ),
//             labelText("repayment_period".tr(), isRequired: true),
//             inputField(hint: "Enter Repayment Period",controller: ),
//             labelText("deduction_start_date".tr(), isRequired: true),
//             CustomDateField(hintText: "select_date".tr()),
//             labelText("note".tr()),
//             inputField(hint: "enter_your_note".tr(), minLines: 3controller: ),
//
//             16.heightBox,
//             const FileUploadButton(),
//
//             50.heightBox,
//           ],
//         ),
//       ),
//       bottomSheet: SafeArea(
//         child: Padding(
//           padding: AppPadding.screenBottomSheetPadding,
//           child: CustomElevatedButton(
//             onPressed: () {
//               final fileData = ref.read(fileUploadProvider).value;
//               final userContext = ref.watch(userContextProvider);
//               final model = LoanSubmitRequestModel(
//                 suconn: userContext.companyConnection,
//                 emcode: userContext.empCode,
//                 lntype: selectedLoanType,
//                 note: noteController.text,
//                 amount: int.tryParse(amountController.text) ?? 0,
//                 reqdate: selectedDate.toIso8601String(),
//                 username: userContext.userName,
//                 paymentperiod: selectedPeriod,
//                 deductiondeductionDate: deductionDate.toIso8601String(),
//                 mediafile: fileData?.base64,
//                 mediaExtension: fileData?.extension,
//                 loid: 0,
//                 baseDirectory: userContext.userBaseUrl,
//               );
//
//               // await ref
//               //     .read(loanSubmitNotifierProvider.notifier)
//               //     .submitLoan(model);
//
//               // Navigator.pop(context);
//             },
//             child: Text(
//               '${submitText.tr()} ',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
