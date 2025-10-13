import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/utils.dart';

import '../common_ui_stuffs.dart';

class CustomDateField extends StatefulWidget {
  final String hintText;
  final String? initialDate;
  final bool? notBeforeInitialDate;
  final bool canChangeDate;
  final void Function(String selectedDate)? onDateSelected;

  const CustomDateField({
    super.key,
    required this.hintText,
    this.initialDate,
    this.onDateSelected,
    this.notBeforeInitialDate,
    this.canChangeDate = true,
  });

  @override
  State<CustomDateField> createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDate ?? '');
  }

  @override
  void didUpdateWidget(covariant CustomDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _controller.text = widget.initialDate ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime initial = DateTime.now();

    // Try to parse initialDate if provided
    if (widget.initialDate != null && widget.initialDate!.isNotEmpty) {
      try {
        initial = DateFormat('dd/MM/yyyy').parse(widget.initialDate!);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate:
          (widget.notBeforeInitialDate ?? false) ? initial : DateTime(1500),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final formatted = DateFormat('dd/MM/yyyy').format(picked);
      _controller.text = formatted;
      widget.onDateSelected?.call(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      onTap: widget.canChangeDate ? () => _pickDate(context) : null,
      decoration: InputDecoration(
        hintText: widget.hintText.tr(),
        suffixIcon: const Icon(Icons.calendar_today_outlined),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }
}

class CustomDateRangePickerField extends StatefulWidget {
  final String hintText;
  final bool? readOnly;
  final void Function(String fromDate, String toDate)? onDateRangeSelected;

  /// Dates in `dd/MM/yyyy` format
  final String? fromDate;
  final String? toDate;

  const CustomDateRangePickerField({
    super.key,
    this.hintText = 'select_date_range',
    this.onDateRangeSelected,
    this.fromDate,
    this.toDate,
    this.readOnly,
  });

  @override
  State<CustomDateRangePickerField> createState() =>
      _CustomDateRangePickerFieldState();
}

class _CustomDateRangePickerFieldState
    extends State<CustomDateRangePickerField> {
  DateTimeRange? _selectedRange;

  String get _formattedRange {
    if (_selectedRange == null) return '';
    final formatter = DateFormat('dd/MM/yyyy');
    return '${formatter.format(_selectedRange!.start)} - ${formatter.format(_selectedRange!.end)}';
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      barrierColor: AppTheme.primaryColor,
      useRootNavigator: true,
      context: context,
      firstDate: DateTime(1500),
      lastDate: DateTime(2030),
      initialDateRange:
          _selectedRange ??
          DateTimeRange(start: now, end: now.add(const Duration(days: 7))),
    );

    if (picked != null) {
      final formatter = DateFormat('dd/MM/yyyy');
      final fromDate = formatter.format(picked.start);
      final toDate = formatter.format(picked.end);

      setState(() {
        _selectedRange = picked;
      });

      widget.onDateRangeSelected?.call(fromDate, toDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse latest values every build
    if (widget.fromDate != null && widget.toDate != null) {
      try {
        final formatter = DateFormat('dd/MM/yyyy');
        final start = formatter.parse(widget.fromDate!);
        final end = formatter.parse(widget.toDate!);
        _selectedRange = DateTimeRange(start: start, end: end);
      } catch (_) {
        _selectedRange = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            labelText("date_from", isRequired: true),
            70.widthBox,
            labelText("date_to", isRequired: true),
          ],
        ),
        TextField(
          readOnly: true,
          onTap: () {
            if (widget.readOnly ?? false) {
              return;
            } else {
              _pickDateRange(context);
            }
          },
          controller: TextEditingController(text: _formattedRange),
          decoration: InputDecoration(
            hintText: widget.hintText.tr(),
            suffixIcon: const Icon(Icons.date_range),
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
      ],
    );
  }
}
