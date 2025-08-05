import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/common_text.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/customDateTime_pickers/month_and_year_picker.dart';
import 'package:zeta_ess/core/common/widgets/customDatePicker_widget.dart';
import 'package:zeta_ess/core/common/widgets/customDropDown_widget.dart';
import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
import 'package:zeta_ess/core/common/widgets/customFilePicker_widget.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/expense_claim/screens/widgets/expense_claim_form.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';

class SubmitExpenseClaimScreen extends ConsumerStatefulWidget {
  const SubmitExpenseClaimScreen({super.key});

  @override
  ConsumerState<SubmitExpenseClaimScreen> createState() =>
      _SubmitExpenseClaimScreenState();
}

class _SubmitExpenseClaimScreenState
    extends ConsumerState<SubmitExpenseClaimScreen> {
  final advanceProvider = StateProvider<bool>((ref) => false);
  final includeBusinessGiftProvider = StateProvider<bool>((ref) => false);
  final TextEditingController monthYearPickerController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final advance = ref.watch(advanceProvider);
    final includeBuss = ref.watch(includeBusinessGiftProvider);

    return DefaultTabController(
      length: 2,

      child: Scaffold(
        appBar: AppBar(title: const Text('Submit Expense Claim Form')),
        body: Padding(
          padding: AppPadding.screenPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelText("Requesting Date: ${formatDate(DateTime.now())}"),
                Row(
                  children: [
                    Expanded(
                      child: detailInfoRow(
                        title: 'Employee Currency',
                        belowValue: 'USD',
                      ),
                    ),
                    Expanded(
                      child: detailInfoRow(
                        title: 'Request Number',
                        belowValue: '3',
                      ),
                    ),
                  ],
                ),

                // labelText("Did you get an advance payment?"),
                // labelText("Does your expense include business gift expense?"),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        labelText("Advance pay received?"),
                        Row(
                          children: [
                            _buildRadio(
                              title: 'Yes',
                              value: true,
                              groupValue: advance,
                              onChanged:
                                  (val) =>
                                      ref.read(advanceProvider.notifier).state =
                                          val!,
                            ),
                            _buildRadio(
                              title: 'No',
                              value: false,
                              groupValue: advance,
                              onChanged:
                                  (val) =>
                                      ref.read(advanceProvider.notifier).state =
                                          val!,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: [
                        labelText("Includes gift expense?"),

                        Row(
                          children: [
                            _buildRadio(
                              title: 'Yes',
                              value: true,
                              groupValue: includeBuss,
                              onChanged:
                                  (val) =>
                                      ref
                                          .read(
                                            includeBusinessGiftProvider
                                                .notifier,
                                          )
                                          .state = val!,
                            ),
                            _buildRadio(
                              title: 'No',
                              value: false,
                              groupValue: includeBuss,
                              onChanged:
                                  (val) =>
                                      ref
                                          .read(
                                            includeBusinessGiftProvider
                                                .notifier,
                                          )
                                          .state = val!,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                3.heightBox,
                CustomDropdown(hintText: 'Claim settlement mode'),
                3.heightBox,

                MonthYearPickerField(
                  label: 'Preferred Date of Payment',
                  controller: monthYearPickerController,
                ),
                const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Expense Details'),
                    Tab(text: 'Supporting Docs'),
                  ],
                ),

                SizedBox(
                  height: 250.h,
                  child: TabBarView(
                    children: [
                      _buildExpenseDetailsTab(),
                      _buildSupportingDocumentsTab(),
                    ],
                  ),
                ),
                titleHeaderText('Summary of your Expense Claim'),
                detailInfoRow(
                  title: 'Expense claim total amount (A)',
                  subTitle: '1000',
                ),
                detailInfoRow(
                  title: 'Business Gift total amount (B)',
                  subTitle: '120',
                ),
                detailInfoRow(
                  title: 'Total amount submitted (A + B)',
                  subTitle: '1212',
                ),
                titleHeaderText('Comment'),
                inputField(hint: 'Enter comment', minLines: 3),
                80.heightBox,
              ],
            ),
          ),
        ),
        bottomSheet: Padding(
          padding: AppPadding.screenBottomSheetPadding,
          child: CustomElevatedButton(
            onPressed: () {},
            child: Text(submitText.tr()),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportingDocumentsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          10.heightBox,

          inputField(hint: 'Enter Expense Number'),
          10.heightBox,
          inputField(hint: 'Enter Description', minLines: 3),

          ///TODO multiple files should be uploaded here !!!!!!
          FileUploadButton(),
        ],
      ),
    );
  }

  Widget _buildExpenseDetailsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelText('Date'),
          CustomDateField(hintText: 'Select Date'),
          labelText('Description'),
          inputField(hint: 'Enter Description', minLines: 5),

          labelText('Currency of Expense'),
          CustomDropdown(hintText: 'Select Currency'),
          labelText('Expense Amount'),
          inputField(hint: 'Enter Expense Amount'),
          labelText('Conversion Rate =- - '),
          labelText('Requested Conversion Rate'),
          detailInfoRow(
            title: 'Amount in Employee Currency',
            belowValue: '100',
          ),
          labelText('Cost Center of Job Number'),
          inputField(hint: 'Enter'),
          labelText('Expense Analysis Action'),
          CustomDropdown(hintText: 'Select'),
          titleHeaderText('Total AED : 1000'),
          15.heightBox,
          CustomElevatedButton(
            onPressed: () {
              NavigationService.navigateToScreen(
                context: context,
                screen: ManyExpenseClaimScreen(),
              );
            },
            child: Text('Add more'),
          ),
        ],
      ),
    );
  }

  /// ✅ Reusable Radio builder
  Widget _buildRadio({
    required String title,
    required bool value,
    required bool groupValue,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Radio<bool>(value: value, groupValue: groupValue, onChanged: onChanged),
        Text(title),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    monthYearPickerController.dispose();
  }
}

class ManyExpenseClaimScreen extends StatefulWidget {
  const ManyExpenseClaimScreen({super.key});

  @override
  _ManyExpenseClaimScreenState createState() => _ManyExpenseClaimScreenState();
}

class _ManyExpenseClaimScreenState extends State<ManyExpenseClaimScreen> {
  final List<ExpenseClaimForm> _claims = [ExpenseClaimForm(key: UniqueKey())];

  void _addNewClaim() {
    setState(() => _claims.add(ExpenseClaimForm(key: UniqueKey())));
  }

  void _removeClaim(Key key) {
    setState(() => _claims.removeWhere((claim) => claim.key == key));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expense Claim Request'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _claims.length,
                  itemBuilder:
                      (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: ExpenseClaimForm(
                          key: _claims[index].key!,
                          onDelete: () => _removeClaim(_claims[index].key!),
                        ),
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: _addNewClaim,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primaryColor,
                ),
                label: Text(
                  'Add Another Expense',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  onPressed: () {},
                  child: Text('Submit', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
