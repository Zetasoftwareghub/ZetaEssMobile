import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';

class ApiErrors {
  static const String userNotFound = '-1';
  static const String passwordIncorrect = '-2';
  static const String severError = '500';
  static const String databaseError = '600';
  static const String unknownError = '-3';
  static const String licenseExpired = '-4';

  static const Set<String> allErrors = {
    passwordIncorrect,
    userNotFound,
    severError,
    databaseError,
    unknownError,
    licenseExpired,
  };

  static bool isError(String? errorCode, BuildContext context) {
    if (errorCode == null || errorCode.isEmpty) return false;

    if (allErrors.contains(errorCode)) {
      String errorMessage = '';

      switch (errorCode) {
        case userNotFound:
          errorMessage = 'userNotFound'.tr();
          break;
        case passwordIncorrect:
          errorMessage = 'incorrect_password'.tr();
          break;
        case severError:
          errorMessage = 'serverError'.tr();
          break;
        case databaseError:
          errorMessage = 'databaseError'.tr();
          break;
        case licenseExpired:
          errorMessage = 'licenseExpiredDetailed'.tr();
          break;
        default:
          errorMessage = 'unknownError'.tr();
      }

      showCustomAlertBox(
        context,
        title: 'error'.tr(),
        content: errorMessage,
        type: AlertType.error,
      );

      return true;
    }
    return false;
  }
}
