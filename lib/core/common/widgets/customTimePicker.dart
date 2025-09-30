import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../utils/time_utils.dart';
import '../common_ui_stuffs.dart';

class CustomTimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final void Function(TimeOfDay)? onTimePicked;

  const CustomTimePickerField({
    super.key,
    required this.label,
    this.selectedTime,
    this.onTimePicked,
  });

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "--:--";
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    suffixIcon: const Icon(Icons.calendar_today_outlined),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
  );

  Future<void> _pickTime(BuildContext context) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? now,
    );
    if (picked != null && onTimePicked != null) {
      onTimePicked!(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickTime(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: _inputDecoration(
            label,
          ).copyWith(hintText: _formatTime(selectedTime)),
        ),
      ),
    );
  }
}

class CustomFromToTimePicker extends StatelessWidget {
  final String? fromTime;
  final String? toTime;
  final void Function(String)? onFromTimeChanged;
  final void Function(String)? onToTimeChanged;

  const CustomFromToTimePicker({
    super.key,
    required this.fromTime,
    required this.toTime,
    required this.onFromTimeChanged,
    required this.onToTimeChanged,
  });

  Future<void> _pickTime({
    required BuildContext context,
    required bool isFrom,
    required TimeOfDay? initialTime,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      final formatted = _format24(picked);

      if (isFrom) {
        onFromTimeChanged?.call(formatted);
        onToTimeChanged?.call("");
      } else {
        if (fromTime != null && !_isToTimeValid(fromTime!, formatted)) {
          showSnackBar(
            context: context,
            content: "To time must be after From time".tr(),
            color: AppTheme.errorColor,
          );
          return;
        }
        onToTimeChanged?.call(formatted);
      }
    }
  }

  bool _isToTimeValid(String from, String to) {
    final fromParts = from.split(":").map(int.parse).toList();
    final toParts = to.split(":").map(int.parse).toList();
    final fromMinutes = fromParts[0] * 60 + fromParts[1];
    final toMinutes = toParts[0] * 60 + toParts[1];
    return toMinutes > fromMinutes;
  }

  String _format24(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  InputDecoration _inputDecoration(String label) => InputDecoration(
    hintText: label,
    suffixIcon: const Icon(Icons.access_time),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: labelText("from_time", isRequired: true)),
            SizedBox(width: 12.w),
            Expanded(child: labelText("to_time", isRequired: true)),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap:
                    () => _pickTime(
                      context: context,
                      isFrom: true,
                      initialTime: formatTime24toAmPmString(fromTime),
                    ),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _inputDecoration(
                      "from_time".tr(),
                    ).copyWith(hintText: fromTime ?? "--:--"),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap:
                    () => _pickTime(
                      context: context,
                      isFrom: false,
                      initialTime: formatTime24toAmPmString(toTime),
                    ),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _inputDecoration(
                      "to_time".tr(),
                    ).copyWith(hintText: toTime ?? "--:--"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
