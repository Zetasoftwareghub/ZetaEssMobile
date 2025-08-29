import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/common/common_ui_stuffs.dart';
import '../../../../../core/common/widgets/customElevatedButton_widget.dart';
import '../../../../../core/theme/common_theme.dart';
import '../../providers/new_providers.dart';
//
// // Model for Advance Payment
// class AdvancePaymentModel {
//   final String id;
//   final String paymentNumber;
//   final String currency;
//   final String amount;
//   final String conversionRate;
//   final String amountInEmployeeCurrency;
//
//   AdvancePaymentModel({
//     required this.id,
//     required this.paymentNumber,
//     required this.currency,
//     required this.amount,
//     required this.conversionRate,
//     required this.amountInEmployeeCurrency,
//   });
//
//   double get totalAmount => double.tryParse(amountInEmployeeCurrency) ?? 0.0;
// }

class AddAdvancePaymentScreen extends ConsumerStatefulWidget {
  final AdvancePaymentModel? existingPayment;

  const AddAdvancePaymentScreen({super.key, this.existingPayment});

  @override
  ConsumerState<AddAdvancePaymentScreen> createState() =>
      _AddAdvancePaymentScreenState();
}

class _AddAdvancePaymentScreenState
    extends ConsumerState<AddAdvancePaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _paymentNumberController;
  late TextEditingController _amountController;
  late TextEditingController _conversionRateController;

  String? selectedCurrency;
  double employeeCurrencyAmount = 0.0;

  @override
  void initState() {
    super.initState();
    final payment = widget.existingPayment;
    _paymentNumberController = TextEditingController(
      text: payment?.paymentNumber ?? '',
    );
    _amountController = TextEditingController(text: payment?.amount ?? '');
    _conversionRateController = TextEditingController(
      text: payment?.conversionRate ?? '3.67',
    );

    if (payment != null) {
      selectedCurrency = payment.currency.isEmpty ? null : payment.currency;
      _calculateEmployeeCurrencyAmount();
    }

    _amountController.addListener(_calculateEmployeeCurrencyAmount);
    _conversionRateController.addListener(_calculateEmployeeCurrencyAmount);
  }

  void _calculateEmployeeCurrencyAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final rate = double.tryParse(_conversionRateController.text) ?? 3.67;
    setState(() {
      employeeCurrencyAmount = amount * rate;
    });
  }

  @override
  void dispose() {
    _paymentNumberController.dispose();
    _amountController.dispose();
    _conversionRateController.dispose();
    super.dispose();
  }

  void _saveAdvancePayment() {
    if (_formKey.currentState!.validate()) {
      final advancePayment = AdvancePaymentModel(
        id: widget.existingPayment?.id ?? const Uuid().v4(),
        paymentNumber: _paymentNumberController.text,
        currency: selectedCurrency ?? '',
        amount: _amountController.text,
        conversionRate: _conversionRateController.text,
        amountInEmployeeCurrency: employeeCurrencyAmount.toStringAsFixed(2),
      );

      // Here you would add to your provider (similar to expense details)
      // ref.read(advancePaymentsProvider.notifier).addAdvancePayment(advancePayment);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingPayment != null
              ? 'Edit Advance Payment'.tr()
              : 'Add Advance Payment'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: _saveAdvancePayment,
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
                labelText('Advance Payment Number'.tr()),
                TextFormField(
                  controller: _paymentNumberController,
                  decoration: InputDecoration(
                    hintText: 'Enter Payment Number'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter payment number'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                labelText('Currency'.tr()),
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
                labelText('Amount'.tr()),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    hintText: 'Enter Amount'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount'.tr();
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
                detailInfoRow(
                  title: 'Amount in Employee Currency (AED)'.tr(),
                  belowValue: employeeCurrencyAmount.toStringAsFixed(2),
                ),
                const SizedBox(height: 32),
                titleHeaderText(
                  '${"Total".tr()} ${selectedCurrency ?? 'AED'}: ${_amountController.text.isEmpty ? '0' : _amountController.text}',
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
            if (widget.existingPayment != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Delete Advance Payment'.tr()),
                            content: Text(
                              'Are you sure you want to delete this advance payment?'
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
            if (widget.existingPayment != null) const SizedBox(width: 16),
            Expanded(
              child: CustomElevatedButton(
                onPressed: _saveAdvancePayment,
                child: Text(
                  widget.existingPayment != null
                      ? 'Update'.tr()
                      : 'Save Payment'.tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
