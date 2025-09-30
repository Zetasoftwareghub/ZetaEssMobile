import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';

import '../../models/regularisation_models.dart';

//
// class RegulariseCalendarDataDisplay extends StatelessWidget {
//   final bool isLoading;
//   final List<AttendanceSummary> summaryData;
//   final List<RequestStatus> requestStatuses;
//   final ValueNotifier<List<AttendanceEvent>> selectedEvents;
//
//   const RegulariseCalendarDataDisplay({
//     super.key,
//     required this.isLoading,
//     required this.summaryData,
//     required this.requestStatuses,
//     required this.selectedEvents,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (isLoading) Loader(),
//           if (summaryData.isNotEmpty)
//             _buildGridSection(
//               title: 'Attendance Summary',
//               items: summaryData,
//               itemBuilder:
//                   (item) => _buildInfoCard(
//                     count: item.count,
//                     text: item.shortCode,
//                     backgroundColor: Color(
//                       int.parse(item.color.replaceAll('#', '0xFF')),
//                     ),
//                     textColor: Colors.white,
//                   ),
//             ),
//           if (requestStatuses.isNotEmpty)
//             _buildGridSection(
//               title: 'Request Status',
//               items: requestStatuses,
//               itemBuilder:
//                   (item) => _buildInfoCard(
//                     count: item.count,
//                     text: item.name,
//                     backgroundColor: Colors.blue.shade100,
//                     textColor: Colors.blue.shade800,
//                   ),
//             ),
//           _buildSelectedDayEvents(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGridSection<T>({
//     required String title,
//     required List<T> items,
//     required Widget Function(T) itemBuilder,
//   }) {
//     return _buildSection(
//       title: title,
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: items.length,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 3.2,
//           crossAxisSpacing: 16.w,
//           mainAxisSpacing: 16.h,
//         ),
//         itemBuilder: (context, index) => itemBuilder(items[index]),
//       ),
//     );
//   }
//
//   Widget _buildSection({required String title, required Widget child}) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 24.h),
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF1D3557),
//             ),
//           ),
//           SizedBox(height: 16.h),
//           child,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoCard({
//     required int count,
//     required String text,
//     required Color backgroundColor,
//     required Color textColor,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(14.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12.withOpacity(0.06),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 42.w,
//             height: 42.w,
//             decoration: BoxDecoration(
//               color: backgroundColor,
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Center(
//               child: Text(
//                 count.toString(),
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSelectedDayEvents() {
//     return ValueListenableBuilder<List<AttendanceEvent>>(
//       valueListenable: selectedEvents,
//       builder: (context, events, _) {
//         if (events.isEmpty) return const SizedBox.shrink();
//         return _buildSection(
//           title: 'Selected Day Details',
//           child: ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: events.length,
//             separatorBuilder: (_, __) => SizedBox(height: 16.h),
//             itemBuilder: (context, index) => _buildEventCard(events[index]),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildEventCard(AttendanceEvent event) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12.withOpacity(0.06),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   event.title,
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               if (event.hasRequest)
//                 Icon(
//                   CupertinoIcons.pin_fill,
//                   color: Colors.deepOrange,
//                   size: 16.w,
//                 ),
//             ],
//           ),
//           SizedBox(height: 12.h),
//           Row(
//             children: [
//               _buildEventDetail('Check In', event.checkIn),
//               SizedBox(width: 20.w),
//               _buildEventDetail('Check Out', event.checkOut),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           _buildEventDetail('Working Hours', event.workingHours),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEventDetail(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Colors.grey.shade600,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: 2.h),
//         Text(
//           value,
//           style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }
// }
class RegulariseCalendarDataDisplay extends StatelessWidget {
  final bool isLoading;
  final List<AttendanceSummary> summaryData;
  final List<RequestStatus> requestStatuses;
  final ValueNotifier<List<AttendanceEvent>> selectedEvents;

  const RegulariseCalendarDataDisplay({
    super.key,
    required this.isLoading,
    required this.summaryData,
    required this.requestStatuses,
    required this.selectedEvents,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Padding(padding: EdgeInsets.all(32.w), child: Loader()),
      );
    }

    final hasData = summaryData.isNotEmpty || requestStatuses.isNotEmpty;

    if (!hasData) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summaryData.isNotEmpty) ...[
            _buildAttendanceSummarySection(),
            SizedBox(height: 16.h),
          ],
          if (requestStatuses.isNotEmpty) ...[
            _buildRequestStatusSection(),
            SizedBox(height: 16.h),
          ],
          _buildSelectedDayEvents(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.calendar_circle,
              size: 48.w,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No attendance data available'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummarySection() {
    return _buildSection(
      title: 'Attendance Summary'.tr(),
      icon: CupertinoIcons.chart_bar_circle_fill,
      iconColor: const Color(0xFF457B9D),
      child: _buildSummaryCards(),
    );
  }

  Widget _buildSummaryCards() {
    return Wrap(
      spacing: 8.w, // Horizontal spacing between items
      runSpacing: 8.h, // Vertical spacing between rows
      children:
          summaryData.map((item) => _buildWrappedSummaryCard(item)).toList(),
    );
  }

  Widget _buildWrappedSummaryCard(AttendanceSummary item) {
    // Calculate width for 3 items per row with spacing
    final screenWidth = 1.sw;
    final cardWidth =
        (screenWidth - 32.w - 16.w) / 4; // Account for padding and spacing

    return SizedBox(
      width: cardWidth,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color:
              item.color == '#FFFFFF'
                  ? AppTheme.primaryColor
                  : Color(int.parse(item.color.replaceAll('#', '0xFF'))),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Color(
                int.parse(item.color.replaceAll('#', '0xFF')),
              ).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.count.toString(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              item.shortCode,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestStatusSection() {
    return _buildSection(
      title: 'Request Status',
      icon: CupertinoIcons.doc_text_fill,
      iconColor: const Color(0xFF2A9D8F),
      child: _buildRequestStatusGrid(),
    );
  }

  Widget _buildRequestStatusGrid() {
    return Column(
      children: [
        for (int i = 0; i < requestStatuses.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
              bottom: i + 2 < requestStatuses.length ? 12.h : 0,
            ),
            child: Row(
              children: [
                Expanded(child: _buildRequestStatusCard(requestStatuses[i])),
                if (i + 1 < requestStatuses.length) ...[
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildRequestStatusCard(requestStatuses[i + 1]),
                  ),
                ] else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRequestStatusCard(RequestStatus item) {
    final statusColor = _getStatusColor(item.name);
    final statusIcon = _getStatusIcon(item.name);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(statusIcon, size: 16.w, color: statusColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.count.toString(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.name.toLowerCase().tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withOpacity(0.1),
                      iconColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 20.w, color: iconColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A202C),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }

  Widget _buildSelectedDayEvents() {
    return ValueListenableBuilder<List<AttendanceEvent>>(
      valueListenable: selectedEvents,
      builder: (context, events, _) {
        if (events.isEmpty) return const SizedBox.shrink();
        return _buildSection(
          title: 'Selected Day Details',
          icon: CupertinoIcons.calendar_today,
          iconColor: const Color(0xFFE63946),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) => _buildEventCard(events[index]),
          ),
        );
      },
    );
  }

  Widget _buildEventCard(AttendanceEvent event) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A202C),
                  ),
                ),
              ),
              if (event.hasRequest)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepOrange.shade100,
                        Colors.deepOrange.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.deepOrange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.pin_fill,
                        color: Colors.deepOrange,
                        size: 14.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Request',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _buildEventDetail(
                  'Check In',
                  event.checkIn,
                  CupertinoIcons.arrow_right_circle_fill,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildEventDetail(
                  'Check Out',
                  event.checkOut,
                  CupertinoIcons.arrow_left_circle_fill,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildEventDetail(
            'Working Hours',
            event.workingHours,
            CupertinoIcons.clock_fill,
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetail(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF457B9D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 14.w, color: const Color(0xFF457B9D)),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A202C),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF2A9D8F);
      case 'pending':
        return const Color(0xFFF77F00);
      case 'rejected':
        return const Color(0xFFE63946);
      default:
        return const Color(0xFF457B9D);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return CupertinoIcons.checkmark_circle_fill;
      case 'pending':
        return CupertinoIcons.clock_fill;
      case 'rejected':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.doc_text_fill;
    }
  }

  String _getFullFormFromCode(String code) {
    switch (code.toUpperCase()) {
      case 'P':
        return 'Present';
      case 'A':
        return 'Absent';
      case 'L':
        return 'Leave';
      case 'H':
        return 'Holiday';
      case 'WO':
        return 'Week Off';
      case 'PH':
        return 'Public Holiday';
      default:
        return code;
    }
  }
}
