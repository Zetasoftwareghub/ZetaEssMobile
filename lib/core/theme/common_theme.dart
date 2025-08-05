import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppPadding {
  static EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 24.w,
  ).copyWith(top: 12.h);

  static EdgeInsets screenBottomSheetPadding = EdgeInsets.symmetric(
    horizontal: 12.w,
  ).copyWith(bottom: 10.h);
}

class AppTextStyles {
  static TextStyle smallFont({
    double? fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 13.sp,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
    );
  }

  static TextStyle mediumFont({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 16.sp,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
    );
  }

  static TextStyle largeFont({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 24.sp,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
    );
  }
}
