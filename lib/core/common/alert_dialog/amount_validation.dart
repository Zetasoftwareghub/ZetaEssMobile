import 'package:flutter/material.dart';

import 'alertBox_function.dart';

bool validateApproveAmount({
  required BuildContext context,
  required TextEditingController controller,
  required String requestedAmount,
}) {
  final enteredAmount = double.tryParse(controller.text) ?? 0.0;
  final maxAmount = double.tryParse(requestedAmount) ?? 0.0;

  if (enteredAmount > maxAmount) {
    showCustomAlertBox(
      context,
      title: 'Approve amount cannot be greater than requested amount',
      type: AlertType.error,
    );
    return false; // ❌ Invalid
  }
  return true; // ✅ Valid
}
