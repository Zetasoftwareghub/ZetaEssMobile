import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/common_text.dart';
import 'package:zeta_ess/core/utils.dart';

import '../theme/app_theme.dart';

Widget labelText(String text, {bool isRequired = false}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 6.h, top: 14.h),
    child: RichText(
      text: TextSpan(
        text: text.tr(),
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.black,
        ), // your base style
        children:
            isRequired
                ? [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
                : [],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget inputField({
  required String hint,
  TextEditingController? controller,
  int? minLines,
  bool isRequired = false,
  bool readOnly = false,
  TextInputType? keyboardType = TextInputType.text,
  void Function(String)? onChanged,
}) {
  return TextFormField(
    readOnly: readOnly,
    validator:
        (value) =>
            isRequired
                ? (value == null || value.trim().isEmpty)
                    ? 'pleaseFillRequiredFields'.tr()
                    : null
                : null,
    controller: controller,
    inputFormatters:
        keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
    onChanged: onChanged,
    maxLines: minLines,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    minLines: 1,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      hintText: hint.tr(),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
    ),
  );
}

Widget titleHeaderText(String title) {
  return Padding(
    padding: EdgeInsets.only(top: 15.h, bottom: 5.h),
    child: Text(
      title.tr(),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
        color: AppTheme.primaryColor,
      ),
    ),
  );
}

//ONLY FOR DETAIL SCREENS
Widget detailInfoRow({
  required String title,
  String? subTitle,
  String? belowValue,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 130.w,
              child: Text(
                title.tr(),
                style: TextStyle(color: Colors.black54, fontSize: 14.sp),
              ),
            ),
            Expanded(
              child: Text(
                (subTitle?.tr() ?? "").isEmpty
                    ? noValueFound.tr()
                    : subTitle!.tr(),
                style: TextStyle(fontSize: 14.sp),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),

        if (belowValue != null)
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(
              belowValue,
              style: TextStyle(fontSize: 14.sp),
              textAlign: TextAlign.start,
            ),
          ),
      ],
    ),
  );
}

//RADIO BUTTON IN ROW
Widget radioButtonContainer({
  required String title,
  required String value,
  required bool isSelected,
  required void Function()? onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 12.h),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.black,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryColor : Colors.black,
            ),
            10.widthBox,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
