import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/features/self_service/attendance_regularisation/screens/widgets/regularise_calendar_data_display.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/regularisation_models.dart';
import '../repository/attendance_regularise_repository.dart';
import 'attendanceRegularisation_screen.dart';

class AttendanceRegularisationDatePick extends ConsumerStatefulWidget {
  final String? restorationId;

  const AttendanceRegularisationDatePick({super.key, this.restorationId});

  @override
  ConsumerState<AttendanceRegularisationDatePick> createState() =>
      _AttendanceRegularisationDatePickState();
}

class _AttendanceRegularisationDatePickState
    extends ConsumerState<AttendanceRegularisationDatePick>
    with WidgetsBindingObserver {
  // Constants
  static const _dojString =
      '30-06-2000 09:00:00'; //TODO give this as a date of joining
  static const _dateFormat = "dd-MM-yyyy HH:mm:ss";
  static const _maxFutureDays = 365;
  static const _requestTimeout = Duration(seconds: 60);

  // Calendar state
  late final ValueNotifier<List<AttendanceEvent>> _selectedEvents;
  var _calendarFormat = CalendarFormat.month;
  var _rangeSelectionMode = RangeSelectionMode.toggledOn;
  var _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // Data state
  final _events = <DateTime, List<AttendanceEvent>>{};
  var _summaryData = <AttendanceSummary>[];
  var _requestStatuses = <RequestStatus>[];
  var _calendarDays = <RegulariseCalendarDay>[];
  var _isLoading = false;

  // Date constraints
  late final DateTime _minDate;
  late final DateTime _maxDate;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  void _initializeDates() {
    _minDate = DateFormat(_dateFormat).parse(_dojString);
    _maxDate = DateTime.now().add(const Duration(days: _maxFutureDays));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Called when screen comes back into focus
      refreshCalendarData();
    }
  }

  List<AttendanceEvent> _getEventsForDay(DateTime day) => _events[day] ?? [];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end ?? start;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null) {
      _fetchAttendanceData(start, end ?? start);
    }
  }

  Future<void> _fetchAttendanceData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final response = await getCalendarData(
        dateFrom: DateFormat('yyyyMMdd').format(startDate),
        dateTo: DateFormat('yyyyMMdd').format(endDate),
        userContext: ref.watch(userContextProvider),
      ).timeout(_requestTimeout);

      if (response != null) {
        _processAttendanceData(response, startDate, endDate);
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch attendance data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _processAttendanceData(
    Map<String, dynamic> response,
    DateTime startDate,
    DateTime endDate,
  ) {
    _clearData();
    _processSummaryData(response['subLst']);
    _processRequestStatuses(response['rejLst']);
    _createCalendarGrid(response, startDate, endDate);
    setState(() {});
  }

  void _clearData() {
    _events.clear();
    _summaryData.clear();
    _requestStatuses.clear();
    _calendarDays.clear();
  }

  void _processSummaryData(List<dynamic>? data) {
    if (data == null) return;
    _summaryData =
        data
            .map(
              (item) => AttendanceSummary(
                name: item['lvpcarname'] ?? '',
                shortCode: item['dLsrdtf'] ?? '',
                count: int.tryParse(item['empName'] ?? '0') ?? 0,
                color: item['lsnote'] ?? '#FFFFFF',
              ),
            )
            .toList();
  }

  void _processRequestStatuses(List<dynamic>? data) {
    if (data == null) return;
    _requestStatuses =
        data
            .map(
              (item) => RequestStatus(
                name: item['dLsrdtf'] ?? '',
                count: int.tryParse(item['empName'] ?? '0') ?? 0,
              ),
            )
            .toList();
  }

  void _createCalendarGrid(
    Map<String, dynamic> response,
    DateTime startDate,
    DateTime endDate,
  ) {
    final tmpDays = <RegulariseCalendarDay>[];

    for (var item in response['canLst'] ?? []) {
      final dateStr = item['lrtpac']?.toString().trim();
      if (dateStr != null &&
          dateStr.length == 8 &&
          RegExp(r'^\d{8}$').hasMatch(dateStr)) {
        _processCalendarItem(item, dateStr, tmpDays);
      }
    }
    _calendarDays = tmpDays;
  }

  void _processCalendarItem(
    Map<String, dynamic> item,
    String dateStr,
    List<RegulariseCalendarDay> tmpDays,
  ) {
    final formattedDate =
        '${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}';
    final newDate = DateTime.parse(formattedDate);
    final dayNumber = int.parse(dateStr.substring(6, 8));

    final existingDay = tmpDays.where(
      (t) => t.date == dateStr && t.date.isNotEmpty,
    );
    if (existingDay.isEmpty) {
      tmpDays.add(
        RegulariseCalendarDay(
          id: dayNumber,
          day: dayNumber.toString(),
          title: item['empName']?.toString() ?? '',
          colorCode: item['dLsdate']?.toString() ?? '#FFFFFF',
          checkIn: item['lsnote']?.toString() ?? '',
          checkOut: item['lvpcarname']?.toString() ?? '',
          workingHours: item['subname']?.toString() ?? '',
          date: dateStr,
          hasRequest: (item['lscont']?.toString() ?? '0') != '0',
        ),
      );
    }

    // Add to events map
    final event = AttendanceEvent(
      title: item['empName']?.toString() ?? '',
      checkIn: item['lsnote']?.toString() ?? '',
      checkOut: item['lvpcarname']?.toString() ?? '',
      workingHours: item['subname']?.toString() ?? '',
      colorCode: item['dLsdate']?.toString() ?? '#FFFFFF',
      hasRequest: (item['lscont']?.toString() ?? '0') != '0',
    );

    _events[newDate] = (_events[newDate] ?? [])..add(event);
  }

  void _showErrorDialog(String message) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Alert'),
            content: Text(message, style: const TextStyle(fontSize: 14)),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Attendance Regularization')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendarSection(),
            RegulariseCalendarDataDisplay(
              isLoading: _isLoading,
              summaryData: _summaryData,
              requestStatuses: _requestStatuses,
              selectedEvents: _selectedEvents,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: const BoxDecoration(
        color: Color(0xFFD5F2FA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendarHeader(),
          SizedBox(height: 16.h),
          _buildTableCalendar(),
          if (_calendarDays.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildCalendarDaysRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Select Date Range',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0B6E96),
          ),
        ),
        IconButton(
          onPressed:
              () => setState(() {
                _calendarFormat =
                    _calendarFormat == CalendarFormat.month
                        ? CalendarFormat.twoWeeks
                        : CalendarFormat.month;
              }),
          icon: Icon(
            _calendarFormat == CalendarFormat.month
                ? Icons.view_agenda
                : Icons.view_module,
            color: const Color(0xFF0B6E96),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCalendar() {
    return Container(
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TableCalendar<AttendanceEvent>(
        calendarStyle: AppTheme.commonTableCalenderStyle,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          leftChevronIcon: Icon(CupertinoIcons.left_chevron, size: 20.w),
          rightChevronIcon: Icon(CupertinoIcons.right_chevron, size: 20.w),
        ),
        firstDay: _minDate,
        lastDay: _maxDate,
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        rangeSelectionMode: _rangeSelectionMode,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,
        onDaySelected: _onDaySelected,
        onRangeSelected: _onRangeSelected,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      ),
    );
  }

  Widget _buildCalendarDaysRow() {
    return Container(
      margin: EdgeInsets.only(top: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: _calendarDays.map(_buildCalendarDayItem).toList()),
      ),
    );
  }

  Widget _buildCalendarDayItem(RegulariseCalendarDay day) {
    final bgColor =
        day.colorCode.isNotEmpty
            ? Color(int.parse(day.colorCode.replaceAll('#', '0xFF')))
            : Colors.grey.shade200;

    final isDarkText = bgColor.computeLuminance() > 0.5;

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttendanceRegularisationScreen(regulariseDay: day),
          ),
        ).then((_) {
          refreshCalendarData();
        });
      },
      child: Container(
        width: 60.w,
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (day.hasRequest)
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(
                  CupertinoIcons.pin_fill,
                  color: Colors.cyan,
                  size: 14.w,
                ),
              ),
            Text(
              day.day,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: isDarkText ? Colors.black87 : Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              day.title,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDarkText ? Colors.black54 : Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> refreshCalendarData() async {
    if (_rangeStart != null) {
      await _fetchAttendanceData(_rangeStart!, _rangeEnd ?? _rangeStart!);
    } else if (_selectedDay != null) {
      await _fetchAttendanceData(_selectedDay!, _selectedDay!);
    }
  }
}
