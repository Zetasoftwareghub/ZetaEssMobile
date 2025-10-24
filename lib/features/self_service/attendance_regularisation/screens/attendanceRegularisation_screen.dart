import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/common_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';
import 'package:zeta_ess/features/self_service/attendance_regularisation/models/regularisation_models.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../core/utils/time_utils.dart';
import '../models/regularise_calendar_models.dart';
import '../models/submit_regularise_model.dart';
import '../providers/regularise_notifier.dart';

class AttendanceRegularisationScreen extends ConsumerStatefulWidget {
  final RegulariseCalendarDay regulariseDay;

  const AttendanceRegularisationScreen({
    super.key,
    required this.regulariseDay,
  });

  @override
  ConsumerState<AttendanceRegularisationScreen> createState() =>
      _AttendanceRegularisationScreenState();
}

class _AttendanceRegularisationScreenState
    extends ConsumerState<AttendanceRegularisationScreen> {
  final TextEditingController _remarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(attendanceRegularizationControllerProvider.notifier)
          .loadCalendarDetails(widget.regulariseDay.date ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceRegularizationControllerProvider);
    final controller = ref.read(
      attendanceRegularizationControllerProvider.notifier,
    );
    _remarkController.text = state.calendarDetails?.remarks ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: Text('Regularise Attendance'.tr())),
      body:
          state.isLoading
              ? const Loader()
              : _buildBody(context, state, controller),
      bottomNavigationBar: _buildBottomNavigationBar(context, controller),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AttendanceRegularizationState state,
    AttendanceRegularizationController controller,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            _buildInfoSection(context),
            SizedBox(height: 24.h),
            _buildPunchingSection(context, state, controller),
            SizedBox(height: 100.h), // Space for floating buttons
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF09A5D9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF09A5D9),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Attendance Details'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  "date".tr(),
                  convertDateYYYMMDDtoStringDate(widget.regulariseDay.date),
                  Icons.event,
                  const Color(0xFF4CAF50),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildInfoCard(
                  context,
                  "Working Hours".tr(),
                  widget.regulariseDay.workingHours ?? '',
                  Icons.schedule,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  "check_in".tr(),
                  widget.regulariseDay.checkIn ?? '',
                  Icons.login,
                  const Color(0xFFFF9800),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildInfoCard(
                  context,
                  "check_out".tr(),
                  widget.regulariseDay.checkOut ?? '',
                  Icons.logout,
                  const Color(0xFFE91E63),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPunchingSection(
    BuildContext context,
    AttendanceRegularizationState state,
    AttendanceRegularizationController controller,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPunchingHeader(context),
          _buildPunchingList(context, state, controller),
        ],
      ),
    );
  }

  Widget _buildPunchingHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF09A5D9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.punch_clock,
              color: Color(0xFF09A5D9),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Punch Details'.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPunchingList(
    BuildContext context,
    AttendanceRegularizationState state,
    AttendanceRegularizationController controller,
  ) {
    if (state.punchingDetails.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40.w),
        child: Column(
          children: [
            Icon(Icons.access_time, size: 48, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              'No records found'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap "Add New" to create a punch entry'.tr(),
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: state.punchingDetails.length,
      itemBuilder: (context, index) {
        final item = state.punchingDetails[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: _buildPunchingItem(context, item, index, controller),
        );
      },
    );
  }

  Widget _buildPunchingItem(
    BuildContext context,
    CalendarPunchingDetails item,
    int index,
    AttendanceRegularizationController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              item.type == 'IN'
                  ? const Color(0xFF4CAF50).withOpacity(0.2)
                  : const Color(0xFFE91E63).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with punch type and actions
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color:
                  item.type == 'IN'
                      ? const Color(0xFF4CAF50).withOpacity(0.08)
                      : const Color(0xFFE91E63).withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        item.type == 'IN'
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE91E63),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.type == 'IN' ? Icons.login : Icons.logout,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.type ?? 'IN',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${'Entry'.tr()} ${index + 1}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _showDeleteConfirmation(context, index, controller);
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content area with date, time, and type controls
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Time Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'date'.tr(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          _buildDateSelector(context, item, index, controller),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'time'.tr(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          _buildTimeSelector(context, item, index, controller),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Type Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Punch Type'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _buildTypeSelector(context, item, index, controller),
                  ],
                ),

                // Location if available
                if (item.location?.isNotEmpty == true) ...[
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location'.tr(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.location ?? '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    CalendarPunchingDetails item,
    int index,
    AttendanceRegularizationController controller,
  ) {
    return InkWell(
      onTap: () async {
        final parsedDate =
            item.date != null &&
                    (item.date?.isNotEmpty ?? false) &&
                    item.date != 'Select Date'
                ? DateFormat('dd-MM-yyyy').parse(item.date!)
                : DateTime.now();

        final picked = await showDatePicker(
          context: context,
          initialDate: parsedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          final formattedDate = DateFormat('dd-MM-yyyy').format(picked);
          controller.updatePunchingDate(index, formattedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: const Color(0xFF09A5D9),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.date ?? 'Select Date'.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      item.date != null ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    CalendarPunchingDetails item,
    int index,
    AttendanceRegularizationController controller,
  ) {
    final punchList =
        ref.watch(attendanceRegularizationControllerProvider).punchingDetails;
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: formatTime24toAmPmString(item.time) ?? TimeOfDay.now(),
        );

        if (picked != null) {
          final formattedTime =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

          final currentItem = punchList[index];

          final isOutTime =
              currentItem.type?.toLowerCase().contains('out') ?? false;

          if (isOutTime) {
            final matchingIn = punchList.firstWhere(
              (e) =>
                  e.date == currentItem.date &&
                  (e.type?.toLowerCase().contains('in') ?? false) &&
                  e.time != null,
              orElse: () => CalendarPunchingDetails(time: null),
            );

            if (matchingIn.time != null) {
              final inTime = _parseTime(matchingIn.time!);
              final selectedTime = _parseTime(formattedTime);

              if (!selectedTime.isAfter(inTime)) {
                showSnackBar(
                  context: context,
                  content: 'Out time must be after In time',
                );
                return;
              }
            }
          }
          controller.updatePunchingTime(index, formattedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 16, color: const Color(0xFF09A5D9)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.time ?? 'select_time'.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      item.time != null ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //TODO make this global !
  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(0, 1, 1, hour, minute);
  }

  Widget _buildTypeSelector(
    BuildContext context,
    CalendarPunchingDetails item,
    int index,
    AttendanceRegularizationController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => controller.updatePunchingType(index, 'IN'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color:
                    item.type == 'IN'
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      item.type == 'IN'
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 14,
                    color:
                        item.type == 'IN' ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'in'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          item.type == 'IN'
                              ? Colors.white
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: GestureDetector(
            onTap: () => controller.updatePunchingType(index, 'OUT'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color:
                    item.type == 'OUT'
                        ? const Color(0xFFE91E63)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      item.type == 'OUT'
                          ? const Color(0xFFE91E63)
                          : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    size: 14,
                    color:
                        item.type == 'OUT'
                            ? Colors.white
                            : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'out'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          item.type == 'OUT'
                              ? Colors.white
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    AttendanceRegularizationController controller,
  ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.addNewPunchingDetail();
                        _showSnackBar(
                          context,
                          'New punch entry added successfully',
                          Colors.green,
                        );
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: Text('Add New'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _showSubmitDialog(context, controller),
                      icon: const Icon(Icons.send, size: 20),
                      label: Text('Send for Approval'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF09A5D9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int index,
    AttendanceRegularizationController controller,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Delete Punch Entry'.tr()),
            content: Text(
              'Are you sure you want to delete this punch entry?'.tr(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'.tr()),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.removePunchingDetail(index);
                  _showSnackBar(
                    context,
                    'Punch entry deleted successfully',
                    Colors.red,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Delete'.tr()),
              ),
            ],
          ),
    );
  }

  void _showSubmitDialog(
    BuildContext context,
    AttendanceRegularizationController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _remarkController = TextEditingController();
        final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading =
                ref.watch(attendanceRegularizationControllerProvider).isLoading;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child:
                      isLoading
                          ? Loader()
                          : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF09A5D9,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.comment,
                                      color: Color(0xFF09A5D9),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Add Remarks'.tr(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _remarkController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter remarks for this regularization request...'
                                          .tr(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF09A5D9),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Remarks cannot be empty'.tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'.tr()),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            isLoading = true;
                                          });

                                          final result = await controller
                                              .buildAndSubmit(
                                                _remarkController.text,
                                                context,
                                              );

                                          setState(() {
                                            isLoading = false;
                                          });

                                          if (result != null) {
                                            Navigator.pop(context);
                                            showCustomAlertBox(
                                              context,
                                              title: result,
                                              type:
                                                  result ==
                                                          'Submitted Successfully'
                                                      ? AlertType.success
                                                      : AlertType.warning,
                                            );
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF09A5D9,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text('Submit'.tr()),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'OK'.tr(),
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }
}
