import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_theme.dart';

class CustomPinPutWidget extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onCompleted;
  const CustomPinPutWidget({
    super.key,
    required this.controller,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Pinput(
      controller: controller,
      length: 4,
      onCompleted: onCompleted,
      pinAnimationType: PinAnimationType.rotation,
      obscureText: true,
      obscuringWidget: Icon(
        Icons.circle,
        size: 8.sp,
        color: Colors.blue.shade800,
      ),

      defaultPinTheme: PinTheme(
        width: 55.w,
        height: 55.h,
        textStyle: TextStyle(fontSize: 20.sp, color: Colors.blue.shade800),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryColor, width: 1.5),
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 60.w,
        height: 62.h,
        textStyle: TextStyle(fontSize: 24.sp, color: AppTheme.primaryColor),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.shade100,
          border: Border.all(color: AppTheme.primaryColor, width: 1.2),
        ),
      ),
    );
  }
}
