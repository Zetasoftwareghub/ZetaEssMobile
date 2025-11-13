import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/common_ui_stuffs.dart';
import 'package:zeta_ess/core/common/customDateTime_pickers/month_and_year_picker.dart';
import 'package:zeta_ess/core/common/widgets/customDropDown_widget.dart';
import 'package:zeta_ess/core/common/widgets/customElevatedButton_widget.dart';
import 'package:zeta_ess/core/common/widgets/customFilePicker_widget.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/utils/date_utils.dart';
import '../providers/expense_claim_providers.dart';
import '../providers/new_providers.dart';
import 'forms/add_more_expnse_claim_screen.dart';
import 'forms/advance_payment_form.dart';
import 'forms/business_gift_form.dart';

class SubmitExpenseClaimForm extends ConsumerStatefulWidget {
  const SubmitExpenseClaimForm({super.key});

  @override
  ConsumerState<SubmitExpenseClaimForm> createState() =>
      _SubmitExpenseClaimScreenState();
}

class _SubmitExpenseClaimScreenState
    extends ConsumerState<SubmitExpenseClaimForm>
    with TickerProviderStateMixin {
  final advanceProvider = StateProvider<bool>((ref) => false);
  final includeBusinessGiftProvider = StateProvider<bool>((ref) => false);
  final TextEditingController monthYearPickerController =
      TextEditingController();

  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    // initialize with initial tabCount
    final advance = ref.read(advanceProvider);
    final includeBuss = ref.read(includeBusinessGiftProvider);
    final tabCount = _getTabCount(advance, includeBuss);
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    monthYearPickerController.dispose();
    super.dispose();
  }

  int _getTabCount(bool advance, bool includeBuss) {
    int count = 2; // Always have Expense Details + Supporting Docs
    if (advance) count++;
    if (includeBuss) count++;
    return count;
  }

  void _updateTabController() {
    final newLength = _getTabCount(
      ref.read(advanceProvider),
      ref.read(includeBusinessGiftProvider),
    );
    if (_tabController.length != newLength) {
      _tabController.dispose();
      _tabController = TabController(length: newLength, vsync: this);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final advance = ref.watch(advanceProvider);
    final includeBuss = ref.watch(includeBusinessGiftProvider);

    final expenseDetails = ref.watch(expenseDetailsProvider);
    final advancePayments = ref.watch(advancePaymentsProvider);
    final businessGifts = ref.watch(businessGiftsProvider);
    final totalExpenseAmount =
        ref.read(expenseDetailsProvider.notifier).totalExpenseAmount;
    final totalAdvanceAmount =
        ref.read(advancePaymentsProvider.notifier).totalAdvanceAmount;
    final totalBusinessGiftAmount =
        ref.read(businessGiftsProvider.notifier).totalGiftAmount;

    return Scaffold(
      appBar: AppBar(title: Text('Submit Expense Claim Form'.tr())),
      body: Padding(
        padding: AppPadding.screenPadding,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              labelText(
                '${"Requesting Date:".tr()} ${formatDate(DateTime.now())}',
              ),
              Row(
                children: [
                  Expanded(
                    child: detailInfoRow(
                      title: 'Employee Currency'.tr(),
                      belowValue: 'USD',
                    ),
                  ),
                  Expanded(
                    child: detailInfoRow(
                      title: 'Request Number'.tr(),
                      belowValue: '3',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      labelText('Advance pay received?'.tr()),
                      Row(
                        children: [
                          _buildRadio(
                            title: 'Yes',
                            value: true,
                            groupValue: advance,
                            onChanged: (val) {
                              ref.read(advanceProvider.notifier).state = val!;
                              // Update tab controller length when advance changes
                              _updateTabController();
                            },
                          ),
                          _buildRadio(
                            title: 'No',
                            value: false,
                            groupValue: advance,
                            onChanged: (val) {
                              ref.read(advanceProvider.notifier).state = val!;
                              _updateTabController();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 170.w,
                        child: labelText('Includes gift expense?'.tr()),
                      ),
                      Row(
                        children: [
                          _buildRadio(
                            title: 'Yes',
                            value: true,
                            groupValue: includeBuss,
                            onChanged: (val) {
                              ref
                                  .read(includeBusinessGiftProvider.notifier)
                                  .state = val!;
                              _updateTabController();
                            },
                          ),
                          _buildRadio(
                            title: 'No',
                            value: false,
                            groupValue: includeBuss,
                            onChanged: (val) {
                              ref
                                  .read(includeBusinessGiftProvider.notifier)
                                  .state = val!;
                              _updateTabController();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              3.heightBox,
              CustomDropdown(hintText: 'Claim settlement mode'.tr()),
              3.heightBox,
              MonthYearPickerField(
                label: 'Preferred Date of Payment'.tr(),
                controller: monthYearPickerController,
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                tabs: _buildTabs(advance, includeBuss),
              ),
              SizedBox(
                height: 200.h,
                child: TabBarView(
                  controller: _tabController,
                  children: _buildTabViews(advance, includeBuss),
                ),
              ),
              titleHeaderText('Summary of your Expense Claim'.tr()),
              detailInfoRow(
                title: 'Expense claim total amount (A)'.tr(),
                subTitle: totalExpenseAmount.toStringAsFixed(2),
              ),
              if (advance)
                detailInfoRow(
                  title: 'Advance payment total amount (B)'.tr(),
                  subTitle: totalAdvanceAmount.toStringAsFixed(2),
                ),
              if (includeBuss)
                detailInfoRow(
                  title: 'Business Gift total amount (C)'.tr(),
                  subTitle: totalBusinessGiftAmount.toStringAsFixed(2),
                ),
              detailInfoRow(
                title: 'Total amount submitted'.tr(),
                subTitle: _calculateTotalAmount(
                  totalExpenseAmount,
                  advance ? totalAdvanceAmount : 0.0,
                  includeBuss ? totalBusinessGiftAmount : 0.0,
                ).toStringAsFixed(2),
              ),
              titleHeaderText('Comment'.tr()),
              inputField(hint: 'Enter comment'.tr(), minLines: 3),
              80.heightBox,
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: AppPadding.screenBottomSheetPadding,
        child: CustomElevatedButton(
          onPressed: () {},
          child: Text('Submit'.tr()),
        ),
      ),
    );
  }

  double _calculateTotalAmount(
    double expenseAmount,
    double advanceAmount,
    double giftAmount,
  ) {
    return expenseAmount + advanceAmount + giftAmount;
  }

  List<Widget> _buildTabs(bool advance, bool includeBuss) {
    List<Widget> tabs = [Tab(text: 'Expense Details'.tr())];

    if (advance) {
      tabs.add(Tab(text: 'Advance Payment'.tr()));
    }

    if (includeBuss) {
      tabs.add(Tab(text: 'Business Gift'.tr()));
    }

    tabs.add(Tab(text: 'Supporting Docs'.tr()));

    return tabs;
  }

  List<Widget> _buildTabViews(bool advance, bool includeBuss) {
    List<Widget> tabViews = [_buildExpenseDetailsTab()];

    if (advance) {
      tabViews.add(_buildAdvancePaymentTab());
    }

    if (includeBuss) {
      tabViews.add(_buildBusinessGiftTab());
    }

    tabViews.add(_buildSupportingDocumentsTab());

    return tabViews;
  }

  Widget _buildAdvancePaymentTab() {
    final advancePayments = ref.watch(advancePaymentsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${"Advance Payments".tr()} (${advancePayments.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.payment, color: Colors.blue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          if (advancePayments.isNotEmpty) ...[
            ...advancePayments.asMap().entries.map((entry) {
              final index = entry.key;
              final payment = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    'Payment #${payment?.paymentNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${"Currency:".tr()} ${payment?.currency}'),
                      Text(
                        '${"Amount:".tr()} ${payment?.currency} ${payment?.amount}',
                      ),
                      Text(
                        '${"Employee Currency:".tr()} AED ${payment?.amountInEmployeeCurrency}',
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 8),
                                Text('Edit'.tr()),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete'.tr(),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        NavigationService.navigateToScreen(
                          context: context,
                          screen: AddAdvancePaymentScreen(
                            existingPayment: payment,
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteAdvancePaymentConfirmation(payment);
                      }
                    },
                  ),
                  onTap: () {
                    NavigationService.navigateToScreen(
                      context: context,
                      screen: AddAdvancePaymentScreen(existingPayment: payment),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 5),
          ],
          SizedBox(
            width: double.infinity,
            child: CustomElevatedButton(
              onPressed: () {
                NavigationService.navigateToScreen(
                  context: context,
                  screen: const AddAdvancePaymentScreen(),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 8),
                  Text(
                    advancePayments.isEmpty
                        ? 'Add Advance Payment'.tr()
                        : 'Add More'.tr(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessGiftTab() {
    final businessGifts = ref.watch(businessGiftsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${"Business Gifts".tr()} (${businessGifts.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.card_giftcard, color: Colors.blue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          if (businessGifts.isNotEmpty) ...[
            ...businessGifts.asMap().entries.map((entry) {
              final index = entry.key;
              final gift = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.purple[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    gift.description.length > 30
                        ? '${gift.description.substring(0, 30)}...'
                        : gift.description,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${"Date:".tr()} ${gift.date}'),
                      Text('${"Company:".tr()} ${gift.guestCompanyName}'),
                      Text('${"Guests:".tr()} ${gift.numberOfGuests}'),
                      Text(
                        '${"Amount:".tr()} ${gift.currency} ${gift.expenseAmount}',
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 8),
                                Text('Edit'.tr()),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete'.tr(),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        NavigationService.navigateToScreen(
                          context: context,
                          screen: AddBusinessGiftScreen(existingGift: gift),
                        );
                      } else if (value == 'delete') {
                        _showDeleteBusinessGiftConfirmation(gift);
                      }
                    },
                  ),
                  onTap: () {
                    NavigationService.navigateToScreen(
                      context: context,
                      screen: AddBusinessGiftScreen(existingGift: gift),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 5),
          ],
          SizedBox(
            width: double.infinity,
            child: CustomElevatedButton(
              onPressed: () {
                NavigationService.navigateToScreen(
                  context: context,
                  screen: const AddBusinessGiftScreen(),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 8),
                  Text(
                    businessGifts.isEmpty
                        ? 'Add Business Gift'.tr()
                        : 'Add More'.tr(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportingDocumentsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          10.heightBox,
          inputField(hint: 'Enter Expense Number'.tr()),
          10.heightBox,
          inputField(hint: 'Enter Description'.tr(), minLines: 3),
          FileUploadButton(),
        ],
      ),
    );
  }

  Widget _buildExpenseDetailsTab() {
    final expenseDetails = ref.watch(expenseDetailsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${"Expense Details".tr()} (${expenseDetails.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.receipt_long, color: Colors.blue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          if (expenseDetails.isNotEmpty) ...[
            ...expenseDetails.asMap().entries.map((entry) {
              final index = entry.key;
              final expense = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    expense.description.length > 30
                        ? '${expense.description.substring(0, 30)}...'
                        : expense.description,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${"Date:".tr()} ${expense.date}'),
                      Text(
                        '${"Amount:".tr()} ${expense.currency} ${expense.expenseAmount}',
                      ),
                      Text('${"Category:".tr()} ${expense.expenseAnalysis}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 8),
                                Text('Edit'.tr()),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete'.tr(),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        NavigationService.navigateToScreen(
                          context: context,
                          screen: AddExpenseDetailScreen(
                            existingExpense: expense,
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(expense);
                      }
                    },
                  ),
                  onTap: () {
                    NavigationService.navigateToScreen(
                      context: context,
                      screen: AddExpenseDetailScreen(existingExpense: expense),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 5),
          ],
          SizedBox(
            width: double.infinity,
            child: CustomElevatedButton(
              onPressed: () {
                NavigationService.navigateToScreen(
                  context: context,
                  screen: const AddExpenseDetailScreen(),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 8),
                  Text(
                    expenseDetails.isEmpty
                        ? 'Add Expense Detail'.tr()
                        : 'Add More'.tr(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ExpenseDetailModel expense) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Expense'.tr()),
            content: Text(
              'Are you sure you want to delete this expense detail?'.tr(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'.tr()),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(expenseDetailsProvider.notifier)
                      .removeExpenseDetail(expense.id);
                  Navigator.pop(context);
                  showSnackBar(
                    context: context,
                    content:
                        '${"Expense claim with amount :".tr()} ${expense.totalAmount} ${"has been deleted successfully.".tr()}',
                  );
                },
                child: Text(
                  'Delete'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showDeleteAdvancePaymentConfirmation(AdvancePaymentModel? payment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Advance Payment'.tr()),
            content: Text(
              'Are you sure you want to delete this advance payment?'.tr(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'.tr()),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(advancePaymentsProvider.notifier)
                      .removeAdvancePayment(payment?.id ?? '');
                  Navigator.pop(context);
                  showSnackBar(
                    context: context,
                    content:
                        '${"Advance payment with amount :".tr()} ${payment?.amountInEmployeeCurrency} AED ${"has been deleted successfully.".tr()}',
                  );
                },
                child: Text(
                  'Delete'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showDeleteBusinessGiftConfirmation(BusinessGiftModel gift) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Business Gift'.tr()),
            content: Text(
              'Are you sure you want to delete this business gift?'.tr(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'.tr()),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(businessGiftsProvider.notifier)
                      .removeBusinessGift(gift.id);
                  Navigator.pop(context);
                  showSnackBar(
                    context: context,
                    content:
                        '${"Business gift with amount :".tr()} ${gift.amountInEmployeeCurrency} AED ${"has been deleted successfully.".tr()}',
                  );
                },
                child: Text(
                  'Delete'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildRadio({
    required String title,
    required bool value,
    required bool groupValue,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Radio<bool>(value: value, groupValue: groupValue, onChanged: onChanged),
        Text(title.tr()),
      ],
    );
  }
}
