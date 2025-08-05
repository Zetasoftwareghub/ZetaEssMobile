import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zeta_ess/features/common/home/widgets/colorDot_card.dart';

import '../../../../core/theme/app_theme.dart';
//
// class CalendarHomeView extends ConsumerStatefulWidget {
//   const CalendarHomeView({super.key});
//
//   @override
//   ConsumerState<CalendarHomeView> createState() => _CalendarHomeViewState();
// }
//
// class _CalendarHomeViewState extends ConsumerState<CalendarHomeView> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _rangeStart;
//   DateTime? _rangeEnd;
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: 100.h,
//       left: 0,
//       right: 0,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildCalendarCard(),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
//             child: DotsRowCard(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCalendarCard() {
//     return Container(
//       padding: EdgeInsets.all(12.w),
//       margin: EdgeInsets.symmetric(horizontal: 20.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TableCalendar(
//         focusedDay: _focusedDay,
//         firstDay: DateTime.utc(2000),
//         lastDay: DateTime.utc(2100),
//         //
//         headerStyle: HeaderStyle(
//           formatButtonVisible: false,
//           titleCentered: true,
//         ),
//
//         calendarFormat: CalendarFormat.month,
//         startingDayOfWeek: StartingDayOfWeek.monday,
//         rangeSelectionMode: RangeSelectionMode.enforced,
//         rangeStartDay: _rangeStart,
//         rangeEndDay: _rangeEnd,
//
//         onRangeSelected: (start, end, focusedDay) {
//           setState(() {
//             _rangeStart = start;
//             _rangeEnd = end;
//             _focusedDay = focusedDay;
//           });
//         },
//         // calendarStyle: AppTheme.commonTableCalenderStyle,
//         calendarStyle: CalendarStyle(
//           // Selected range styles
//           rangeStartDecoration: BoxDecoration(
//             color: AppTheme.primaryColor,
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.white, width: 2),
//           ),
//           rangeEndDecoration: BoxDecoration(
//             color: AppTheme.primaryColor,
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.white, width: 2),
//           ),
//           withinRangeDecoration: BoxDecoration(
//             color: AppTheme.primaryColor.withOpacity(0.2),
//             shape: BoxShape.circle,
//           ),
//
//           // Today style
//           todayDecoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.redAccent.shade100, Colors.redAccent.shade400],
//             ),
//
//             shape: BoxShape.circle,
//           ),
//           todayTextStyle: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 13.sp,
//           ),
//
//           // Selected day style
//           selectedDecoration: BoxDecoration(
//             color: AppTheme.primaryColor,
//             shape: BoxShape.circle,
//           ),
//           selectedTextStyle: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 13.sp,
//           ),
//
//           // Default day style
//           defaultTextStyle: TextStyle(fontSize: 13.sp, color: Colors.black87),
//
//           // Weekend style
//           weekendTextStyle: TextStyle(
//             fontSize: 13.sp,
//             color: Colors.redAccent.shade200,
//           ),
//
//           // Outside days (from previous/next month)
//           outsideTextStyle: TextStyle(
//             fontSize: 13.sp,
//             color: Colors.grey.shade400,
//           ),
//
//           // Disable dots/highlight on disabled days
//           disabledTextStyle: TextStyle(
//             fontSize: 13.sp,
//             color: Colors.grey.shade300,
//           ),
//
//           // Cell margin/padding for spacing
//           cellMargin: EdgeInsets.all(4),
//           cellPadding: EdgeInsets.all(4),
//         ),
//       ),
//     );
//   }
// }

class CalendarHomeView extends ConsumerStatefulWidget {
  const CalendarHomeView({super.key});

  @override
  ConsumerState<CalendarHomeView> createState() => _CalendarHomeViewState();
}

class _CalendarHomeViewState extends ConsumerState<CalendarHomeView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // Static holiday dates for UI design
  final List<DateTime> _holidays = [
    DateTime(2025, 1, 1), // New Year's Day
    DateTime(2025, 1, 26), // Republic Day
    DateTime(2025, 3, 14), // Holi
    DateTime(2025, 8, 15), // Independence Day
    DateTime(2025, 10, 2), // Gandhi Jayanti
    DateTime(2025, 10, 24), // Dussehra
    DateTime(2025, 11, 12), // Diwali
    DateTime(2025, 12, 25), // Christmas
    DateTime(2025, 7, 15), // Random holiday
    DateTime(2025, 9, 5), // Random holiday
    DateTime(2025, 11, 8), // Random holiday
  ];

  // Static leave dates for UI design
  final List<DateTime> _leaveDates = [
    DateTime(2025, 2, 14), // Personal leave
    DateTime(2025, 4, 10), // Sick leave
    DateTime(2025, 6, 20), // Vacation
    DateTime(2025, 8, 22), // Personal leave
    DateTime(2025, 10, 15), // Vacation
    DateTime(2025, 12, 30), // Year-end leave
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.h,
      left: 0,
      right: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendarCard(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
            child: DotsRowCard(),
          ),
        ],
      ),
    );
  }

  // Helper method to check if a date is a holiday
  bool _isHoliday(DateTime day) {
    return _holidays.any(
      (holiday) =>
          holiday.year == day.year &&
          holiday.month == day.month &&
          holiday.day == day.day,
    );
  }

  // Helper method to check if a date is a leave day
  bool _isLeaveDay(DateTime day) {
    return _leaveDates.any(
      (leave) =>
          leave.year == day.year &&
          leave.month == day.month &&
          leave.day == day.day,
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2000),
        lastDay: DateTime.utc(2100),

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),

        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        rangeSelectionMode: RangeSelectionMode.enforced,
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,

        // Add calendar builders for custom styling
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            if (_isHoliday(day)) {
              return Container(
                margin: EdgeInsets.all(4),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade300, width: 1),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }
            if (_isLeaveDay(day)) {
              return Container(
                margin: EdgeInsets.all(4),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.shade300, width: 1),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }
            return null; // Use default styling
          },
          todayBuilder: (context, day, focusedDay) {
            if (_isHoliday(day)) {
              return Container(
                margin: EdgeInsets.all(4),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade200, Colors.green.shade400],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              );
            }
            if (_isLeaveDay(day)) {
              return Container(
                margin: EdgeInsets.all(4),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade200, Colors.orange.shade400],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              );
            }
            return null; // Use default today styling
          },
        ),

        onRangeSelected: (start, end, focusedDay) {
          setState(() {
            _rangeStart = start;
            _rangeEnd = end;
            _focusedDay = focusedDay;
          });
        },

        calendarStyle: CalendarStyle(
          // Selected range styles
          rangeStartDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          rangeEndDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          withinRangeDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),

          // Today style
          todayDecoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent.shade100, Colors.redAccent.shade400],
            ),

            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),

          // Selected day style
          selectedDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),

          // Default day style
          defaultTextStyle: TextStyle(fontSize: 13.sp, color: Colors.black87),

          // Weekend style
          weekendTextStyle: TextStyle(
            fontSize: 13.sp,
            color: Colors.redAccent.shade200,
          ),

          // Outside days (from previous/next month)
          outsideTextStyle: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade400,
          ),

          // Disable dots/highlight on disabled days
          disabledTextStyle: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade300,
          ),

          // Cell margin/padding for spacing
          cellMargin: EdgeInsets.all(4),
          cellPadding: EdgeInsets.all(4),
        ),
      ),
    );
  }
}
