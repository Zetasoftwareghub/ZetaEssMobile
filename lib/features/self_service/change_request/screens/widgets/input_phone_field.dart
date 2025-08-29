import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget inputPhoneField({
  required String hint,
  required TextEditingController controller,
  bool isRequired = false,
  bool readOnly = false,
  void Function(String)? onChanged,
}) {
  // Split the initial value (example: "91-92020200")
  final parts = controller.text.split('-');
  final ccController = TextEditingController(
    text: parts.isNotEmpty ? parts.first : "",
  );
  final numController = TextEditingController(
    text: parts.length > 1 ? parts.sublist(1).join('-') : "",
  );

  void updateCombined() {
    controller.text =
        "${ccController.text.trim()}-${numController.text.trim()}";
    if (onChanged != null) onChanged(controller.text);
  }

  return Row(
    children: [
      // Country Code Field
      SizedBox(
        width: 70.w,
        child: TextFormField(
          controller: ccController,
          readOnly: readOnly,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "+CC",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          onChanged: (_) => updateCombined(),
        ),
      ),
      SizedBox(width: 8.w),

      // Phone Number Field
      Expanded(
        child: TextFormField(
          controller: numController,
          readOnly: readOnly,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: hint.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return 'pleaseFillRequiredFields'.tr();
            }
            return null;
          },
          onChanged: (_) => updateCombined(),
        ),
      ),
    ],
  );
}
