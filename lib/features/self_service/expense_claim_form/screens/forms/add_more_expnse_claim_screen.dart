import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/common/widgets/customDropDown_widget.dart';

import '../../../../../core/common/common_ui_stuffs.dart';
import '../../../../../core/common/widgets/customDatePicker_widget.dart';
import '../../../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../../../core/theme/common_theme.dart';
import '../../../expense_claim/providers/expense_claim_providers.dart';
import '../../models/expense_detail_model.dart';
import '../../providers/api_providers.dart';

class AddExpenseDetailScreen extends ConsumerStatefulWidget {
  final ClaimDetail? existingExpense;

  const AddExpenseDetailScreen({super.key, this.existingExpense});

  @override
  ConsumerState<AddExpenseDetailScreen> createState() =>
      _AddExpenseDetailScreenState();
}

class _AddExpenseDetailScreenState
    extends ConsumerState<AddExpenseDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _dateController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _currencyController = TextEditingController();
  TextEditingController _expenseAmountController = TextEditingController();
  TextEditingController _costCenterController = TextEditingController();
  TextEditingController _expenseAnalysisController = TextEditingController();

  String? selectedCurrency;
  String? selectedExpenseAnalysis;

  double conversionRate = 3.67;
  double employeeCurrencyAmount = 0.0;

  @override
  void initState() {
    super.initState();
    final expense = widget.existingExpense;
    // _dateController = TextEditingController(text: expense?.date ?? '');
    // _descriptionController = TextEditingController(
    //   text: expense?.description ?? '',
    // );
    // _currencyController = TextEditingController(text: expense?.currency ?? '');
    // _expenseAmountController = TextEditingController(
    //   text: expense?.expenseAmount ?? '',
    // );
    // _costCenterController = TextEditingController(
    //   text: expense?.costCenter ?? '',
    // );
    // _expenseAnalysisController = TextEditingController(
    //   text: expense?.expenseAnalysis ?? '',
    // );

    if (expense != null) {
      // selectedCurrency = expense.currency.isEmpty ? null : expense.currency;
      // selectedExpenseAnalysis =
      //     expense.expenseAnalysis.isEmpty ? null : expense.expenseAnalysis;
      _calculateEmployeeCurrencyAmount();
    }
    // _expenseAmountController.addListener(_calculateEmployeeCurrencyAmount);
  }

  void _calculateEmployeeCurrencyAmount() {
    final amount = double.tryParse(_expenseAmountController.text) ?? 0.0;
    setState(() {
      employeeCurrencyAmount = amount * conversionRate;
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _currencyController.dispose();
    _expenseAmountController.dispose();
    _costCenterController.dispose();
    _expenseAnalysisController.dispose();
    super.dispose();
  }

  void _saveExpenseDetail() {
    final expenseDetail = ClaimDetail(
      // id: widget.existingExpense?.id ?? const Uuid().v4(),
      // date: _dateController.text,
      // description: _descriptionController.text,
      // currency: selectedCurrency ?? '',
      // expenseAmount: _expenseAmountController.text,
      // costCenter: _costCenterController.text,
      // expenseAnalysis: selectedExpenseAnalysis ?? '',
      // amountInEmployeeCurrency: employeeCurrencyAmount.toStringAsFixed(2),
    );

    // if (widget.existingExpense != null) {
    //   ref
    //       .read(expenseDetailsProvider.notifier)
    //       .updateExpenseDetail(widget.existingExpense!.id, expenseDetail);
    // } else {
    //   ref.read(expenseDetailsProvider.notifier).addExpenseDetail(expenseDetail);
    // }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingExpense != null
              ? 'Edit Expense Detail'.tr()
              : 'Add Expense Detail'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: _saveExpenseDetail,
            child: Text(
              'SAVE'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: AppPadding.screenPadding,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelText('Date'.tr()),
                CustomDateField(hintText: 'Select Date'.tr()),
                labelText('Description'.tr()),
                inputField(
                  hint: 'Enter Description',
                  controller: _descriptionController,
                  minLines: 3,
                ),
                const SizedBox(height: 16),
                labelText('Currency of Expense'.tr()),
                ref
                    .watch(currencyListProvider)
                    .when(
                      data: (currencyList) {
                        return CustomDropdown(
                          hintText: 'Currency of Expense',
                          items:
                              currencyList
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.crcode,
                                      child: Text(e.currencyName ?? ''),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (s) {},
                        );
                      },
                      error:
                          (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                      loading: () => Loader(),
                    ),
                const SizedBox(height: 16),
                labelText('Expense Amount'.tr()),
                TextFormField(
                  controller: _expenseAmountController,
                  decoration: InputDecoration(
                    hintText: 'Enter Expense Amount'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expense amount'.tr();
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                labelText('Conversion Rate = $conversionRate'),
                labelText('Requested Conversion Rate'.tr()),
                detailInfoRow(
                  title: 'Amount in Employee Currency (AED)'.tr(),
                  belowValue: employeeCurrencyAmount.toStringAsFixed(2),
                ),
                const SizedBox(height: 16),
                labelText('Cost Center or Job Number'.tr()),
                TextFormField(
                  controller: _costCenterController,
                  decoration: InputDecoration(
                    hintText: 'Enter Cost Center'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cost center'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                labelText('Expense Analysis Action'.tr()),
                DropdownButtonFormField<String>(
                  value: selectedExpenseAnalysis,
                  decoration: InputDecoration(
                    hintText: 'Select Analysis Action'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  items:
                      [
                        'Travel & Accommodation',
                        'Meals & Entertainment',
                        'Transportation',
                        'Office Supplies',
                        'Training & Development',
                        'Other',
                      ].map((analysis) {
                        return DropdownMenuItem(
                          value: analysis,
                          child: Text(analysis.tr()),
                        );
                      }).toList(),
                  onChanged:
                      (value) => setState(() {
                        selectedExpenseAnalysis = value;
                      }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select expense analysis'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                titleHeaderText(
                  '${"Total".tr()} ${selectedCurrency ?? 'AED'}: ${_expenseAmountController.text.isEmpty ? '0' : _expenseAmountController.text}',
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: AppPadding.screenBottomSheetPadding,
        child: Row(
          children: [
            if (widget.existingExpense != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Delete Expense'.tr()),
                            content: Text(
                              'Are you sure you want to delete this expense detail?'
                                  .tr(),
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
                                      .removeExpenseDetail(
                                        widget.existingExpense!.detailId ?? '',
                                      );
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Delete'.tr(),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                  child: Text('Delete'.tr()),
                ),
              ),
            if (widget.existingExpense != null) const SizedBox(width: 16),
            Expanded(
              child: CustomElevatedButton(
                onPressed: _saveExpenseDetail,
                child: Text(
                  widget.existingExpense != null
                      ? 'Update'.tr()
                      : 'Save Expense'.tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
