import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';

void showSnackBar({
  required BuildContext context,
  required String content,
  Color? color,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(content.tr()),
        backgroundColor: color ?? AppTheme.primaryColor,
      ),
    );
}

extension SpaceExtensions on num {
  SizedBox get heightBox => SizedBox(height: h.h);
  SizedBox get widthBox => SizedBox(width: w.w);

  double get responsiveHeight => h;
  double get responsiveWidth => w;
}

final listTabs = ["submitted".tr(), "approved".tr(), "rejected".tr()];
final approvalListTabs = ["Pending".tr(), "approved".tr(), "rejected".tr()];

final now = DateTime.now();
final greeting =
    now.hour < 12
        ? "Good Morning"
        : now.hour < 17
        ? "Good Afternoon"
        : "Good Evening";

void printFullJson(dynamic json) {
  final prettyString = const JsonEncoder.withIndent('  ').convert(json);
  debugPrint(prettyString, wrapWidth: 1024); // wrap prevents truncation
}
