import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MonthYearPickerField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const MonthYearPickerField({
    super.key,
    required this.controller,
    required this.label,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<MonthYearPickerField> createState() => _MonthYearPickerFieldState();
}

class _MonthYearPickerFieldState extends State<MonthYearPickerField> {
  Future<void> _pickMonthYear(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = widget.initialDate ?? now;
    final firstDate = widget.firstDate ?? DateTime(2000);
    final lastDate = widget.lastDate ?? DateTime(now.year + 10);

    final picked = await showDialog<DateTime>(
      context: context,
      builder:
          (context) => MonthYearPickerDialog(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
          ),
    );

    if (picked != null) {
      final formatted = DateFormat('MM-yyyy').format(picked);
      setState(() => widget.controller.text = formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickMonthYear(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: widget.controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: 'MM-YYYY',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
            suffixIcon: const Icon(Icons.calendar_month_outlined),
          ),
        ),
      ),
    );
  }
}

class MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const MonthYearPickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int selectedYear;
  late int selectedMonth;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
    _pageController = PageController(
      initialPage: selectedYear - widget.firstDate.year,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get monthNames => [
    'January'.tr(),
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  bool _isMonthEnabled(int year, int month) {
    final date = DateTime(year, month);
    final firstDate = DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastDate = DateTime(widget.lastDate.year, widget.lastDate.month);

    return date.isAfter(firstDate.subtract(const Duration(days: 1))) &&
        date.isBefore(lastDate.add(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: 320.w,
        height: 400.h,
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Month & Year',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Year Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed:
                      selectedYear > widget.firstDate.year
                          ? () {
                            setState(() {
                              selectedYear--;
                              _pageController.animateToPage(
                                selectedYear - widget.firstDate.year,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            });
                          }
                          : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  selectedYear.toString(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed:
                      selectedYear < widget.lastDate.year
                          ? () {
                            setState(() {
                              selectedYear++;
                              _pageController.animateToPage(
                                selectedYear - widget.firstDate.year,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            });
                          }
                          : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Month Grid
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    selectedYear = widget.firstDate.year + index;
                  });
                },
                itemCount: widget.lastDate.year - widget.firstDate.year + 1,
                itemBuilder: (context, yearIndex) {
                  final year = widget.firstDate.year + yearIndex;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: 12,
                    itemBuilder: (context, monthIndex) {
                      final month = monthIndex + 1;
                      final isSelected =
                          selectedMonth == month && selectedYear == year;
                      final isEnabled = _isMonthEnabled(year, month);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap:
                              isEnabled
                                  ? () {
                                    setState(() {
                                      selectedMonth = month;
                                      selectedYear = year;
                                    });
                                  }
                                  : null,
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                monthNames[monthIndex].substring(0, 3),
                                style: TextStyle(
                                  color:
                                      isEnabled
                                          ? (isSelected
                                              ? Colors.white
                                              : Colors.black87)
                                          : Colors.grey.shade400,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 20.h),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(DateTime(selectedYear, selectedMonth));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text('OK', style: TextStyle(fontSize: 14.sp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
