import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../core/common/common_text.dart';
import '../../../../core/common/common_ui_stuffs.dart';
import '../../../../core/common/customDateTime_pickers/month_and_year_picker.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customDropDown_widget.dart';
import '../../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../../core/theme/common_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../controller/expenseClaim_controller.dart';
import '../models/expense_claim_model.dart';
import '../providers/expense_claim_providers.dart';

class SubmitExpenseClaimScreen extends ConsumerStatefulWidget {
  final String? claimId;
  const SubmitExpenseClaimScreen({super.key, this.claimId});

  @override
  ConsumerState<SubmitExpenseClaimScreen> createState() =>
      _SubmitExpenseClaimScreenState();
}

class _SubmitExpenseClaimScreenState
    extends ConsumerState<SubmitExpenseClaimScreen> {
  final TextEditingController monthYearController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final selectedAllowance = StateProvider<String>((ref) => '');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isEditMode = false;
  bool hasPreFilled = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.claimId != null;
  }

  void prefillFieldsIfNeeded(ExpenseClaimModel? model) {
    if (hasPreFilled || model == null) return;
    monthYearController.text = model.monthyear ?? '';
    noteController.text = model.note ?? '';
    amountController.text = model.amount ?? '';
    Future.microtask(() {
      ref.read(selectedAllowance.notifier).state =
          model.allowanceCode.toString();
    });
    hasPreFilled = true;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(expenseClaimControllerProvider);

    final AsyncValue<ExpenseClaimModel?>? details =
        isEditMode
            ? ref.watch(
              expenseClaimDetailsProvider(
                int.tryParse(widget.claimId ?? '0') ?? 0,
              ),
            )
            : null;

    final data = details?.maybeWhen(data: (d) => d, orElse: () => null);
    if (data != null) prefillFieldsIfNeeded(data);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode
              ? '${'Edit'.tr()} ${'expense_claim_request'.tr()}'
              : '${submitText.tr()} ${'expense_claim_request'.tr()}',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child:
            details?.when(
              loading: () => const Loader(),
              error: (err, _) => ErrorText(error: err.toString()),
              data: (_) => _buildForm(context, isLoading, data?.reqdate),
            ) ??
            _buildForm(context, isLoading, null), // when not in edit mode
      ),
      bottomSheet:
          isLoading
              ? Loader()
              : SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        monthYearController.text.isNotEmpty &&
                        ref.watch(selectedAllowance).isNotEmpty) {
                      final expenseClaim = ExpenseClaimModel(
                        monthyear: monthYearController.text,
                        reqdate:
                            data?.reqdate ??
                            DateTime.now().toString().split(' ')[0],
                        note: noteController.text,
                        amount: amountController.text,
                        allowanceCode: int.parse(ref.watch(selectedAllowance)),
                        crcode: '0',
                        url: '',
                        expnam: '',
                        iEcid: int.parse(widget.claimId ?? '0'),
                      );

                      ref
                          .read(expenseClaimControllerProvider.notifier)
                          .submitExpenseClaim(
                            expenseClaim: expenseClaim,
                            context: context,
                            isEditMode: isEditMode,
                          );
                    } else {
                      showCustomAlertBox(
                        context,
                        title: "pleaseFillRequiredFields".tr(),
                        type: AlertType.error,
                      );
                    }
                  },
                  child: Text(
                    isEditMode ? updateText.tr() : submitText.tr(),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    bool isLoading,
    String? submittedDate,
  ) {
    return Padding(
      padding: AppPadding.screenPadding,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            submittedDate == null
                ? labelText('submitting_date'.tr())
                : labelText('submitted_date'.tr()),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                submittedDate ?? formatDate(DateTime.now()),
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            12.heightBox,
            labelText('requested_month_and_year'.tr(), isRequired: true),
            MonthYearPickerField(
              controller: monthYearController,
              label: "select_duration".tr(),
            ),
            12.heightBox,
            labelText('amount'.tr(), isRequired: true),
            inputField(
              hint: "enter".tr(),
              keyboardType: TextInputType.number,
              controller: amountController,
            ),
            12.heightBox,
            labelText('note'.tr()),
            inputField(
              hint: 'enter_your_note'.tr(),
              minLines: 3,
              controller: noteController,
              isRequired: false,
            ),
            12.heightBox,
            labelText('expense_claim'.tr(), isRequired: true),

            ref
                .watch(allowanceTypesProvider)
                .when(
                  data: (allowanceTypes) {
                    final selected = ref.watch(selectedAllowance);

                    if (selected.isEmpty && allowanceTypes.isNotEmpty) {
                      Future.microtask(() {
                        ref.read(selectedAllowance.notifier).state =
                            allowanceTypes.first.allowanceValue ?? '';
                      });
                    }

                    return CustomDropdown(
                      onChanged: (allowanceValue) {
                        ref.read(selectedAllowance.notifier).state =
                            allowanceValue ?? "0";
                      },
                      items:
                          allowanceTypes
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e.allowanceValue,
                                  child: Text(e.allowanceType ?? ''),
                                ),
                              )
                              .toList(),
                      value: selected.isEmpty ? null : selected,
                      hintText: "select_type".tr(),
                    );
                  },
                  error: (error, _) => ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),

            100.heightBox,

            // FileUploadButton(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    monthYearController.dispose();
    noteController.dispose();
    amountController.dispose();
    hasPreFilled = false;
  }
}
