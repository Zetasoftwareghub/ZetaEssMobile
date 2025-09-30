import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShiftWidget extends ConsumerStatefulWidget {
  final String date;
  const ShiftWidget({super.key, required this.date});

  @override
  ConsumerState<ShiftWidget> createState() => _ShiftWidgetState();
}

class _ShiftWidgetState extends ConsumerState<ShiftWidget> {
  String? shiftValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: TextField(
        controller: TextEditingController(text: shiftValue),
        decoration:   InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Shift".tr(),
        ),
      ),
    );
  }
}
