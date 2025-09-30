import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../common/alert_dialog/alertBox_function.dart';

class ValidatorServices {
  static bool validateCommentAndShowAlert({
    required BuildContext context,
    required TextEditingController controller,
    String alertMessage = 'Please give reject comment',
  }) {
    if (controller.text.trim().isEmpty) {
      showCustomAlertBox(
        context,
        title: alertMessage.tr(),
        type: AlertType.error,
      );
      return true;
    }
    return false;
  }

  static bool validateApproveAmount({
    required BuildContext context,
    required TextEditingController controller,
    required String requestedAmount,
  }) {
    final enteredAmount = double.tryParse(controller.text) ?? 0.0;
    final maxAmount = double.tryParse(requestedAmount) ?? 0.0;
    if (controller.text == '0') {
      showCustomAlertBox(
        context,
        title: 'Approve amount cannot be zero'.tr(),
        type: AlertType.error,
      );
      return false;
    }

    if (enteredAmount > maxAmount) {
      showCustomAlertBox(
        context,
        title: 'Approve amount cannot be greater than requested amount'.tr(),
        type: AlertType.error,
      );
      return false; // ❌ Invalid
    }
    return true; // ✅ Valid
  }
}
