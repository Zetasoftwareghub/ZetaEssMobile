import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/common/common_ui_stuffs.dart';
import '../../../../../core/common/widgets/customDatePicker_widget.dart';
import '../../../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../../../core/theme/common_theme.dart';
import '../../providers/new_providers.dart';

// // Model for Business Gift
// class BusinessGiftModel {
//   final String id;
//   final String date;
//   final String giftNumber;
//   final String description;
//   final String numberOfGuests;
//   final String guestCompanyName;
//   final String currency;
//   final String expenseAmount;
//   final String conversionRate;
//   final String requestedConversionRate;
//   final String amountInEmployeeCurrency;
//   final String costCenter;
//
//   BusinessGiftModel({
//     required this.id,
//     required this.date,
//     required this.giftNumber,
//     required this.description,
//     required this.numberOfGuests,
//     required this.guestCompanyName,
//     required this.currency,
//     required this.expenseAmount,
//     required this.conversionRate,
//     required this.requestedConversionRate,
//     required this.amountInEmployeeCurrency,
//     required this.costCenter,
//   });
//
//   double get totalAmount => double.tryParse(amountInEmployeeCurrency) ?? 0.0;
// }

class AddBusinessGiftScreen extends ConsumerStatefulWidget {
  final BusinessGiftModel? existingGift;

  const AddBusinessGiftScreen({super.key, this.existingGift});

  @override
  ConsumerState<AddBusinessGiftScreen> createState() =>
      _AddBusinessGiftScreenState();
}

class _AddBusinessGiftScreenState extends ConsumerState<AddBusinessGiftScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dateController;
  late TextEditingController _giftNumberController;
  late TextEditingController _descriptionController;
  late TextEditingController _numberOfGuestsController;
  late TextEditingController _guestCompanyController;
  late TextEditingController _expenseAmountController;
  late TextEditingController _conversionRateController;
  late TextEditingController _requestedConversionRateController;
  late TextEditingController _costCenterController;

  String? selectedCurrency;
  double employeeCurrencyAmount = 0.0;
  double defaultConversionRate = 3.67;

  @override
  void initState() {
    super.initState();
    final gift = widget.existingGift;

    _dateController = TextEditingController(text: gift?.date ?? '');
    _giftNumberController = TextEditingController(text: gift?.giftNumber ?? '');
    _descriptionController = TextEditingController(
      text: gift?.description ?? '',
    );
    _numberOfGuestsController = TextEditingController(
      text: gift?.numberOfGuests ?? '',
    );
    _guestCompanyController = TextEditingController(
      text: gift?.guestCompanyName ?? '',
    );
    _expenseAmountController = TextEditingController(
      text: gift?.expenseAmount ?? '',
    );
    _conversionRateController = TextEditingController(
      text: gift?.conversionRate ?? defaultConversionRate.toString(),
    );
    _requestedConversionRateController = TextEditingController(
      text: gift?.requestedConversionRate ?? defaultConversionRate.toString(),
    );
    _costCenterController = TextEditingController(text: gift?.costCenter ?? '');

    if (gift != null) {
      selectedCurrency = gift.currency.isEmpty ? null : gift.currency;
      _calculateEmployeeCurrencyAmount();
    }

    _expenseAmountController.addListener(_calculateEmployeeCurrencyAmount);
    _requestedConversionRateController.addListener(
      _calculateEmployeeCurrencyAmount,
    );
  }

  void _calculateEmployeeCurrencyAmount() {
    final amount = double.tryParse(_expenseAmountController.text) ?? 0.0;
    final rate =
        double.tryParse(_requestedConversionRateController.text) ??
        defaultConversionRate;
    setState(() {
      employeeCurrencyAmount = amount * rate;
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _giftNumberController.dispose();
    _descriptionController.dispose();
    _numberOfGuestsController.dispose();
    _guestCompanyController.dispose();
    _expenseAmountController.dispose();
    _conversionRateController.dispose();
    _requestedConversionRateController.dispose();
    _costCenterController.dispose();
    super.dispose();
  }

  void _saveBusinessGift() {
    if (_formKey.currentState!.validate()) {
      final businessGift = BusinessGiftModel(
        id: widget.existingGift?.id ?? const Uuid().v4(),
        date: _dateController.text,
        giftNumber: _giftNumberController.text,
        description: _descriptionController.text,
        numberOfGuests: _numberOfGuestsController.text,
        guestCompanyName: _guestCompanyController.text,
        currency: selectedCurrency ?? '',
        expenseAmount: _expenseAmountController.text,
        conversionRate: _conversionRateController.text,
        requestedConversionRate: _requestedConversionRateController.text,
        amountInEmployeeCurrency: employeeCurrencyAmount.toStringAsFixed(2),
        costCenter: _costCenterController.text,
      );

      // Here you would add to your provider (similar to expense details)
      // ref.read(businessGiftsProvider.notifier).addBusinessGift(businessGift);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingGift != null
              ? 'Edit Business Gift'.tr()
              : 'Add Business Gift'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: _saveBusinessGift,
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
                CustomDateField(
                  hintText: 'Select Date'.tr(),
                  // controller: _dateController,
                ),
                const SizedBox(height: 16),
                labelText('Number'.tr()),
                TextFormField(
                  controller: _giftNumberController,
                  decoration: InputDecoration(
                    hintText: 'Enter Gift Number'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter gift number'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                labelText('Description'.tr()),
                inputField(
                  hint: 'Enter Description'.tr(),
                  controller: _descriptionController,
                  minLines: 3,
                ),
                const SizedBox(height: 16),
                labelText('Number of Guests'.tr()),
                TextFormField(
                  controller: _numberOfGuestsController,
                  decoration: InputDecoration(
                    hintText: 'Enter Number of Guests'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of guests'.tr();
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                labelText('Guest\'s Company Name'.tr()),
                TextFormField(
                  controller: _guestCompanyController,
                  decoration: InputDecoration(
                    hintText: 'Enter Guest\'s Company Name'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter guest\'s company name'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                labelText('Currency of Expense'.tr()),
                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  decoration: InputDecoration(
                    hintText: 'Select Currency'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  items:
                      ['USD', 'AED', 'EUR', 'GBP', 'INR']
                          .map(
                            (currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(() {
                        selectedCurrency = value;
                      }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select currency'.tr();
                    }
                    return null;
                  },
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
                labelText('Conversion Rate'.tr()),
                TextFormField(
                  controller: _conversionRateController,
                  decoration: InputDecoration(
                    hintText: 'Enter Conversion Rate'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter conversion rate'.tr();
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                labelText('Requested Conversion Rate'.tr()),
                TextFormField(
                  controller: _requestedConversionRateController,
                  decoration: InputDecoration(
                    hintText: 'Enter Requested Conversion Rate'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter requested conversion rate'.tr();
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                detailInfoRow(
                  title: 'Amount in Employee Currency (AED)'.tr(),
                  belowValue: employeeCurrencyAmount.toStringAsFixed(2),
                ),
                const SizedBox(height: 16),
                labelText('Cost Centre or Job Number'.tr()),
                TextFormField(
                  controller: _costCenterController,
                  decoration: InputDecoration(
                    hintText: 'Enter Cost Centre'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cost centre'.tr();
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
            if (widget.existingGift != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Delete Business Gift'.tr()),
                            content: Text(
                              'Are you sure you want to delete this business gift?'
                                  .tr(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'.tr()),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Handle delete logic here
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
            if (widget.existingGift != null) const SizedBox(width: 16),
            Expanded(
              child: CustomElevatedButton(
                onPressed: _saveBusinessGift,
                child: Text(
                  widget.existingGift != null
                      ? 'Update'.tr()
                      : 'Save Gift'.tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
