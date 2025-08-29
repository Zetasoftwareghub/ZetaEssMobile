import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>>? items;
  final T? value;
  final void Function(T?)? onChanged;
  final String hintText;

  const CustomDropdown({
    super.key,
    this.items,
    this.value,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: onChanged == null,
      child: DropdownButtonFormField<T>(
        items: items,
        onChanged: onChanged ?? (val) {},
        menuMaxHeight: 250.h,
        isExpanded: true,
        value: value,
        style: AppTextStyles.mediumFont(color: Colors.black),
        disabledHint: Text(
          value?.toString() ?? hintText.tr(),
          style: AppTextStyles.mediumFont(color: Colors.black),
        ),
        decoration: InputDecoration(
          hintText: hintText.tr(),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppTheme.primaryColor),
          ),

          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
      ),
    );
  }
}
