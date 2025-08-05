import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// //TODO old code perfect working !
// class CustomDropdown extends StatelessWidget {
//   final List<DropdownMenuItem<String>>? items;
//   final String? value;
//   final void Function(String?)? onChanged;
//   final String hintText;
//   const CustomDropdown({
//     super.key,
//     this.items,
//     this.value,
//     required this.hintText,
//     this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonFormField<String>(
//       items: items,
//       onChanged: onChanged,
//       menuMaxHeight: 250.h,
//       value: value,
//       decoration: InputDecoration(
//         hintText: hintText.tr(),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//         ),
//       ),
//     );
//   }
// }

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
    return DropdownButtonFormField<T>(
      items: items,
      onChanged: onChanged,
      menuMaxHeight: 250.h,
      isExpanded: true,
      value: value,
      decoration: InputDecoration(
        hintText: hintText.tr(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }
}
