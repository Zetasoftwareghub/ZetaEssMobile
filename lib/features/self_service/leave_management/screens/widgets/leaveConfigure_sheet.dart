import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeaveConfigBottomSheet extends StatefulWidget {
  final String dateFrom, dateTo, leaveCode;
  const LeaveConfigBottomSheet({
    super.key,
    required this.dateFrom,
    required this.dateTo,
    required this.leaveCode,
  });

  @override
  State<LeaveConfigBottomSheet> createState() => _LeaveConfigBottomSheetState();
}

class _LeaveConfigBottomSheetState extends State<LeaveConfigBottomSheet> {
  final Map<String, bool> dayTypeMap = {
    "12/10/2025": true,
    "13/10/2025": true,
    "14/10/2025": true,
  };

  void toggleDayType(String date) {
    setState(() {
      dayTypeMap[date] = !(dayTypeMap[date] ?? true);
    });
  }

  @override
  Widget build(BuildContext context) {
    double columnWidth = 100.w;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        Text(
          "Leave Configuration",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        Divider(height: 24.h, thickness: 1),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  children: [
                    SizedBox(
                      width: 130.w,
                      child: Center(
                        child: Text(
                          "date".tr(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: columnWidth,
                      child: Center(
                        child: Text(
                          "Full Day".tr(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: columnWidth,
                      child: Center(
                        child: Text(
                          "Half Day".tr(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              ...dayTypeMap.entries.map((entry) {
                final date = entry.key;
                final isFullDay = entry.value;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Row(
                    children: [
                      SizedBox(width: 130.w, child: Center(child: Text(date))),
                      SizedBox(
                        width: columnWidth,
                        child: Center(
                          child: IconButton(
                            icon: Icon(
                              isFullDay
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isFullDay ? Colors.green : Colors.grey,
                            ),
                            onPressed: () => toggleDayType(date),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: columnWidth,
                        child: Center(
                          child: IconButton(
                            icon: Icon(
                              !isFullDay
                                  ? Icons.cancel
                                  : Icons.radio_button_unchecked,
                              color: !isFullDay ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => toggleDayType(date),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Configure'.tr()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
