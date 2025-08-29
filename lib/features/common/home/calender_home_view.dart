import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/common/screens/drawer_screens/downloads_screen.dart';
import 'package:zeta_ess/features/common/screens/drawer_screens/holiday_calendar_screen.dart';
import 'package:zeta_ess/features/common/screens/leaveBalances_screen.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/providers/userContext_provider.dart';
import '../../../core/services/NavigationService.dart';
import '../../self_service/attendance_regularisation/models/regularisation_models.dart';
import '../../self_service/attendance_regularisation/repository/attendance_regularise_repository.dart';
import '../../self_service/attendance_regularisation/screens/attendanceRegularisation_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/widgets/customDrawer.dart';
import 'home_screen.dart';

class CalendarHomeView extends ConsumerStatefulWidget {
  final bool showCheckInOut;
  const CalendarHomeView({super.key, required this.showCheckInOut});

  @override
  ConsumerState<CalendarHomeView> createState() => _CalendarHomeViewState();
}

class _CalendarHomeViewState extends ConsumerState<CalendarHomeView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Constants
  static const _dojString = '30-06-2000 09:00:00';
  static const _dateFormat = "dd-MM-yyyy HH:mm:ss";
  static const _maxFutureDays = 365;
  static const _requestTimeout = Duration(seconds: 60);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation Controllers
  late AnimationController _summaryAnimationController;
  late AnimationController _calendarAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _summaryAnimation;
  late Animation<double> _calendarAnimation;
  late Animation<double> _fabAnimation;

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
  var _isRefreshing = false;

  // Date constraints
  late final DateTime _minDate;
  late final DateTime _maxDate;

  // UI State
  bool _isCalendarExpanded = true;
  final PageController _summaryPageController = PageController();
  int _currentSummaryPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDates();
    final now = DateTime.now();

    _selectedDay = now;
    _rangeStart = DateTime(now.year, now.month, 1);
    _rangeEnd = now;
    _rangeSelectionMode = RangeSelectionMode.toggledOn;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialAnimations();
      _onRangeSelected(_rangeStart, _rangeEnd, _focusedDay);
    });
  }

  void _initializeAnimations() {
    _summaryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _calendarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _summaryAnimation = CurvedAnimation(
      parent: _summaryAnimationController,
      curve: Curves.elasticOut,
    );
    _calendarAnimation = CurvedAnimation(
      parent: _calendarAnimationController,
      curve: Curves.easeOutCubic,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.bounceOut,
    );
  }

  void _startInitialAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _summaryAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _calendarAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      _fabAnimationController.forward();
    });
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _fetchAttendanceData(_rangeStart!, _rangeEnd!);
      _initialized = true;
    }
  }

  void _initializeDates() {
    _minDate = DateFormat(_dateFormat).parse(_dojString);
    _maxDate = DateTime.now().add(const Duration(days: _maxFutureDays));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _summaryAnimationController.dispose();
    _calendarAnimationController.dispose();
    _fabAnimationController.dispose();
    _summaryPageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
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

      // Haptic feedback for better UX
      HapticFeedback.lightImpact();
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
      _showErrorSnackBar('Failed to fetch attendance data: ${e.toString()}');
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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => refreshCalendarData(),
        ),
      ),
    );
  }

  Widget _buildEnhancedTopRow() {
    final user = ref.read(userDataProvider);
    final now = DateTime.now();
    final greeting =
        now.hour < 12
            ? "Good Morning"
            : now.hour < 17
            ? "Good Afternoon"
            : "Good Evening";

    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/dashboardTopCard.png'),
        ),
        /*  gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
            Colors.deepPurple.shade400,
          ],
        ),*/
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Row(
            children: [
              _buildMenuButton(),
              16.widthBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      user?.empName ?? 'Employee',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showCheckInOut) _buildCalendarToggle(),
              SizedBox(width: 12.w),
              _buildNotificationButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return InkWell(
      onTap: () => scaffoldKey.currentState?.openDrawer(),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.menu_rounded, size: 24.sp, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarToggle() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(toggleCalendarProvider.notifier).state =
            !ref.watch(toggleCalendarProvider);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color:
              ref.watch(toggleCalendarProvider)
                  ? Colors.white
                  : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                ref.watch(toggleCalendarProvider)
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          CupertinoIcons.calendar,
          color:
              ref.watch(toggleCalendarProvider)
                  ? AppTheme.primaryColor
                  : Colors.white,
          size: 22.sp,
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return InkWell(
      onTap:
          () => NavigationService.navigateToScreen(
            context: context,
            screen: NotificationsScreen(),
          ),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Icon(CupertinoIcons.bell, color: Colors.white, size: 22.sp),
            if (_requestStatuses.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSummarySection() {
    if (_summaryData.isEmpty && _requestStatuses.isEmpty)
      return const SizedBox();

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(_summaryAnimation),
      child: FadeTransition(
        opacity: _summaryAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_summaryData.isNotEmpty) ...[
              // Header with title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Monthly Overview',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Horizontal scrollable cards
              SizedBox(
                height: 110.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _summaryData.length,
                  separatorBuilder: (context, index) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    return _buildStunningSmallCard(_summaryData[index]);
                  },
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStunningSmallCard(AttendanceSummary summary) {
    final color = Color(int.parse(summary.color.replaceAll('#', '0xFF')));

    return TweenAnimationBuilder<double>(
      duration: Duration(
        milliseconds: 600 + (300 * _summaryData.indexOf(summary)),
      ),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Container(
            width: 110.w, // Compact width
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.95),
                  color,
                  color.withOpacity(0.85),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                // Main shadow
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                // Inner glow effect
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                children: [
                  // Subtle pattern overlay
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top section with icon and badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon with subtle background
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Icon(
                                _getIconForSummaryType(summary.shortCode),
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),

                            // Short code badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                summary.shortCode,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Bottom section with count and name
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Count with glowing effect
                            ShaderMask(
                              shaderCallback:
                                  (bounds) => LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.8),
                                    ],
                                  ).createShader(bounds),
                              child: Text(
                                '${summary.count}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // Name
                            Text(
                              summary.name,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Enhanced icon method with more variety
  IconData _getIconForSummaryType(String shortCode) {
    switch (shortCode.toLowerCase()) {
      case 'p':
        return CupertinoIcons.checkmark_seal_fill;
      case 'a':
        return CupertinoIcons.xmark_seal_fill;
      case 'l':
        return CupertinoIcons.calendar_badge_minus;
      case 'h':
        return CupertinoIcons.house_fill;
      case 'od':
        return CupertinoIcons.briefcase_fill;
      case 'ml':
        return CupertinoIcons.heart_fill;
      case 'sl':
        return CupertinoIcons.moon_fill;
      default:
        return CupertinoIcons.info_circle_fill;
    }
  }
  //CLAUDE old summary cards

  // Widget _buildEnhancedSummarySection() {
  //   if (_summaryData.isEmpty && _requestStatuses.isEmpty)
  //     return const SizedBox();
  //
  //   return SlideTransition(
  //     position: Tween<Offset>(
  //       begin: const Offset(0, 0.5),
  //       end: Offset.zero,
  //     ).animate(_summaryAnimation),
  //     child: FadeTransition(
  //       opacity: _summaryAnimation,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           if (_summaryData.isNotEmpty) ...[
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'Attendance Summary',
  //                   style: TextStyle(
  //                     fontSize: 18.sp,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.grey[800],
  //                   ),
  //                 ),
  //                 if (_summaryData.length > 2)
  //                   Row(
  //                     children: List.generate(
  //                       (_summaryData.length / 2).ceil(),
  //                       (index) => AnimatedContainer(
  //                         duration: const Duration(milliseconds: 300),
  //                         width: _currentSummaryPage == index ? 20.w : 8.w,
  //                         height: 4.h,
  //                         margin: EdgeInsets.only(right: 4.w),
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(2.r),
  //                           color:
  //                               _currentSummaryPage == index
  //                                   ? AppTheme.primaryColor
  //                                   : Colors.grey[300],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //             SizedBox(height: 16.h),
  //             SizedBox(
  //               height: 140.h,
  //               child: PageView.builder(
  //                 controller: _summaryPageController,
  //                 onPageChanged:
  //                     (index) => setState(() => _currentSummaryPage = index),
  //                 itemCount: (_summaryData.length / 2).ceil(),
  //                 itemBuilder: (context, pageIndex) {
  //                   final startIndex = pageIndex * 2;
  //                   final endIndex = math.min(
  //                     startIndex + 2,
  //                     _summaryData.length,
  //                   );
  //
  //                   return Row(
  //                     children: [
  //                       for (int i = startIndex; i < endIndex; i++) ...[
  //                         Expanded(
  //                           child: _buildEnhancedSummaryCard(_summaryData[i]),
  //                         ),
  //                         if (i < endIndex - 1) SizedBox(width: 12.w),
  //                       ],
  //                     ],
  //                   );
  //                 },
  //               ),
  //             ),
  //             SizedBox(height: 24.h),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildEnhancedSummaryCard(AttendanceSummary summary) {
  //   final color = Color(int.parse(summary.color.replaceAll('#', '0xFF')));
  //
  //   return Container(
  //     padding: EdgeInsets.all(20.w),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [color.withOpacity(0.9), color, color.withOpacity(0.8)],
  //       ),
  //       borderRadius: BorderRadius.circular(24.r),
  //       boxShadow: [
  //         BoxShadow(
  //           color: color.withOpacity(0.4),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Container(
  //               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.2),
  //                 borderRadius: BorderRadius.circular(12.r),
  //               ),
  //               child: Text(
  //                 summary.shortCode,
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 11.sp,
  //                   fontWeight: FontWeight.w700,
  //                 ),
  //               ),
  //             ),
  //             Icon(
  //               _getIconForSummaryType(summary.shortCode),
  //               color: Colors.white.withOpacity(0.8),
  //               size: 20.sp,
  //             ),
  //           ],
  //         ),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               '${summary.count}',
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 32.sp,
  //                 fontWeight: FontWeight.w900,
  //                 height: 1,
  //               ),
  //             ),
  //             SizedBox(height: 4.h),
  //             Text(
  //               summary.name,
  //               style: TextStyle(
  //                 color: Colors.white.withOpacity(0.9),
  //                 fontSize: 13.sp,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //               maxLines: 2,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // IconData _getIconForSummaryType(String shortCode) {
  //   switch (shortCode.toLowerCase()) {
  //     case 'p':
  //       return CupertinoIcons.checkmark_circle;
  //     case 'a':
  //       return CupertinoIcons.xmark_circle;
  //     case 'l':
  //       return CupertinoIcons.calendar_badge_minus;
  //     case 'h':
  //       return CupertinoIcons.house;
  //     default:
  //       return CupertinoIcons.info_circle;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      drawerEdgeDragWidth: 75.w,
      drawer: CustomDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.h),
        child: _buildEnhancedTopRow(),
      ),
      body: RefreshIndicator(
        onRefresh: refreshCalendarData,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    _buildEnhancedSummarySection(),
                    _buildEnhancedCalendarSection(),
                    if (_requestStatuses.isNotEmpty)
                      _buildRequestStatusSection(),
                    SizedBox(height: 100.h), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _showQuickActions(),
          backgroundColor: AppTheme.primaryColor,
          elevation: 8,
          icon: Icon(CupertinoIcons.add, color: Colors.white),
          label: Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedCalendarSection() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(_calendarAnimation),
      child: FadeTransition(
        opacity: _calendarAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar View',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12.h),

            if (_calendarDays.isNotEmpty && _isCalendarExpanded) ...[
              _buildEnhancedCalendarDaysRow(),
            ],
          ],
        ),
      ),
    );
  }

  // Widget _buildEnhancedTableCalendar() {
  //   return Container(
  //     padding: EdgeInsets.all(16.w),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20.r),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.08),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: TableCalendar<AttendanceEvent>(
  //       calendarStyle: AppTheme.commonTableCalenderStyle,
  //       headerStyle: HeaderStyle(
  //         formatButtonVisible: false,
  //         titleCentered: true,
  //         titleTextStyle: TextStyle(
  //           fontSize: 18.sp,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.grey[800],
  //         ),
  //         leftChevronIcon: Icon(CupertinoIcons.chevron_left, size: 20.sp),
  //         rightChevronIcon: Icon(CupertinoIcons.chevron_right, size: 20.sp),
  //       ),
  //       firstDay: _minDate,
  //       lastDay: _maxDate,
  //       focusedDay: _focusedDay,
  //       calendarFormat: _calendarFormat,
  //       rangeSelectionMode: _rangeSelectionMode,
  //       eventLoader: _getEventsForDay,
  //       startingDayOfWeek: StartingDayOfWeek.monday,
  //       selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
  //       rangeStartDay: _rangeStart,
  //       rangeEndDay: _rangeEnd,
  //       onDaySelected: _onDaySelected,
  //       onRangeSelected: _onRangeSelected,
  //       onFormatChanged: (_) {
  //         // if (_calendarFormat != format) {
  //         //   setState(() => _calendarFormat = format);
  //         // }
  //       },
  //       onPageChanged: (focusedDay) => _focusedDay = focusedDay,
  //     ),
  //   );
  // }

  Widget _buildEnhancedCalendarDaysRow() {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _calendarDays.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _buildEnhancedCalendarDayItem(_calendarDays[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEnhancedCalendarDayItem(RegulariseCalendarDay day) {
    final bgColor =
        day.colorCode.isNotEmpty
            ? Color(int.parse(day.colorCode.replaceAll('#', '0xFF')))
            : const Color(0xFF6C5CE7);

    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () async {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    AttendanceRegularisationScreen(regulariseDay: day),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              );
            },
          ),
        ).then((_) => refreshCalendarData());
      },
      child: Container(
        width: 90.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor.withOpacity(0.9),
              bgColor,
              bgColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (day.hasRequest)
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.exclamationmark,
                        color: Colors.white,
                        size: 10.sp,
                      ),
                    )
                  else
                    const SizedBox(),
                  Icon(
                    CupertinoIcons.clock,
                    color: Colors.white.withOpacity(0.7),
                    size: 14.sp,
                  ),
                ],
              ),
              Text(
                day.day,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24.sp,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Text(
                day.title.length > 6
                    ? '${day.title.substring(0, 6)}...'
                    : day.title,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Text(
          'Pending Requests',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children:
              _requestStatuses.map(_buildEnhancedRequestStatusChip).toList(),
        ),
      ],
    );
  }

  Widget _buildEnhancedRequestStatusChip(RequestStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.red.shade100],
        ),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            '${status.name} (${status.count})',
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickActionItem(
                      icon: Icons.event_available,
                      label: 'Leave Balances',
                      color: Colors.blue,
                      onTap: () {
                        NavigationService.navigateToScreen(
                          context: context,
                          screen: LeaveBalancesScreen(title: 'leave_balances'),
                        );
                      },
                    ),
                    _buildQuickActionItem(
                      icon: Icons.calendar_month,
                      label: 'Holiday Calendar',
                      color: Colors.orange,
                      onTap: () {
                        NavigationService.navigateToScreen(
                          context: context,
                          screen: HolidayCalendar(),
                        );
                      },
                    ),
                    _buildQuickActionItem(
                      icon: Icons.download_for_offline,
                      label: 'Downloads',
                      color: Colors.green,
                      onTap: () {
                        NavigationService.navigateToScreen(
                          context: context,
                          screen: DownloadsScreen(),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 80.w,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> refreshCalendarData() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      if (_rangeStart != null) {
        await _fetchAttendanceData(_rangeStart!, _rangeEnd ?? _rangeStart!);
      } else if (_selectedDay != null) {
        await _fetchAttendanceData(_selectedDay!, _selectedDay!);
      }

      HapticFeedback.lightImpact();
      //TODO refresh logic here
    } catch (e) {
      _showErrorSnackBar('Failed to refresh calendar');
    } finally {
      setState(() => _isRefreshing = false);
    }
  }
} //
// class CalendarHomeView extends ConsumerStatefulWidget {
//   final bool showCheckInOut;
//   const CalendarHomeView({super.key, required this.showCheckInOut});
//
//   @override
//   ConsumerState<CalendarHomeView> createState() => _CalendarHomeViewState();
// }
//
// class _CalendarHomeViewState extends ConsumerState<CalendarHomeView>
//     with WidgetsBindingObserver {
//   // Constants
//   static const _dojString =
//       '30-06-2000 09:00:00'; //TODO give this as a date of joining
//   static const _dateFormat = "dd-MM-yyyy HH:mm:ss";
//   static const _maxFutureDays = 365;
//   static const _requestTimeout = Duration(seconds: 60);
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//
//   // Calendar state
//   late final ValueNotifier<List<AttendanceEvent>> _selectedEvents;
//   var _calendarFormat = CalendarFormat.month;
//   var _rangeSelectionMode = RangeSelectionMode.toggledOn;
//   var _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   DateTime? _rangeStart;
//   DateTime? _rangeEnd;
//
//   // Data state
//   final _events = <DateTime, List<AttendanceEvent>>{};
//   var _summaryData = <AttendanceSummary>[];
//   var _requestStatuses = <RequestStatus>[];
//   var _calendarDays = <RegulariseCalendarDay>[];
//   var _isLoading = false;
//
//   // Date constraints
//   late final DateTime _minDate;
//   late final DateTime _maxDate;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeDates();
//     final now = DateTime.now();
//
//     _selectedDay = now;
//
//     // 👇 Initialize range from 1st of current month to today
//     _rangeStart = DateTime(now.year, now.month, 1);
//     _rangeEnd = now;
//
//     _rangeSelectionMode = RangeSelectionMode.toggledOn;
//
//     _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _onRangeSelected(_rangeStart, _rangeEnd, _focusedDay);
//     });
//   }
//
//   bool _initialized = false;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_initialized) {
//       _fetchAttendanceData(_rangeStart!, _rangeEnd!);
//       _initialized = true;
//     }
//   }
//
//   void _initializeDates() {
//     _minDate = DateFormat(_dateFormat).parse(_dojString);
//     _maxDate = DateTime.now().add(const Duration(days: _maxFutureDays));
//   }
//
//   @override
//   void dispose() {
//     _selectedEvents.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // Called when screen comes back into focus
//       refreshCalendarData();
//     }
//   }
//
//   List<AttendanceEvent> _getEventsForDay(DateTime day) => _events[day] ?? [];
//
//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     if (!isSameDay(_selectedDay, selectedDay)) {
//       setState(() {
//         _selectedDay = selectedDay;
//         _focusedDay = focusedDay;
//         _rangeStart = _rangeEnd = null;
//         _rangeSelectionMode = RangeSelectionMode.toggledOff;
//       });
//       _selectedEvents.value = _getEventsForDay(selectedDay);
//     }
//   }
//
//   void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
//     setState(() {
//       _selectedDay = null;
//       _focusedDay = focusedDay;
//       _rangeStart = start;
//       _rangeEnd = end ?? start;
//       _rangeSelectionMode = RangeSelectionMode.toggledOn;
//     });
//
//     if (start != null) {
//       _fetchAttendanceData(start, end ?? start);
//     }
//   }
//
//   Future<void> _fetchAttendanceData(
//     DateTime startDate,
//     DateTime endDate,
//   ) async {
//     if (_isLoading) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       final response = await getCalendarData(
//         dateFrom: DateFormat('yyyyMMdd').format(startDate),
//         dateTo: DateFormat('yyyyMMdd').format(endDate),
//         userContext: ref.watch(userContextProvider),
//       ).timeout(_requestTimeout);
//
//       if (response != null) {
//         _processAttendanceData(response, startDate, endDate);
//       }
//     } catch (e) {
//       _showErrorDialog('Failed to fetch attendance data');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _processAttendanceData(
//     Map<String, dynamic> response,
//     DateTime startDate,
//     DateTime endDate,
//   ) {
//     _clearData();
//     _processSummaryData(response['subLst']);
//     _processRequestStatuses(response['rejLst']);
//     _createCalendarGrid(response, startDate, endDate);
//     setState(() {});
//   }
//
//   void _clearData() {
//     _events.clear();
//     _summaryData.clear();
//     _requestStatuses.clear();
//     _calendarDays.clear();
//   }
//
//   void _processSummaryData(List<dynamic>? data) {
//     if (data == null) return;
//     _summaryData =
//         data
//             .map(
//               (item) => AttendanceSummary(
//                 name: item['lvpcarname'] ?? '',
//                 shortCode: item['dLsrdtf'] ?? '',
//                 count: int.tryParse(item['empName'] ?? '0') ?? 0,
//                 color: item['lsnote'] ?? '#FFFFFF',
//               ),
//             )
//             .toList();
//   }
//
//   void _processRequestStatuses(List<dynamic>? data) {
//     if (data == null) return;
//     _requestStatuses =
//         data
//             .map(
//               (item) => RequestStatus(
//                 name: item['dLsrdtf'] ?? '',
//                 count: int.tryParse(item['empName'] ?? '0') ?? 0,
//               ),
//             )
//             .toList();
//   }
//
//   void _createCalendarGrid(
//     Map<String, dynamic> response,
//     DateTime startDate,
//     DateTime endDate,
//   ) {
//     final tmpDays = <RegulariseCalendarDay>[];
//
//     for (var item in response['canLst'] ?? []) {
//       final dateStr = item['lrtpac']?.toString().trim();
//       if (dateStr != null &&
//           dateStr.length == 8 &&
//           RegExp(r'^\d{8}$').hasMatch(dateStr)) {
//         _processCalendarItem(item, dateStr, tmpDays);
//       }
//     }
//     _calendarDays = tmpDays;
//   }
//
//   void _processCalendarItem(
//     Map<String, dynamic> item,
//     String dateStr,
//     List<RegulariseCalendarDay> tmpDays,
//   ) {
//     final formattedDate =
//         '${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}';
//     final newDate = DateTime.parse(formattedDate);
//     final dayNumber = int.parse(dateStr.substring(6, 8));
//
//     final existingDay = tmpDays.where(
//       (t) => t.date == dateStr && t.date.isNotEmpty,
//     );
//     if (existingDay.isEmpty) {
//       tmpDays.add(
//         RegulariseCalendarDay(
//           id: dayNumber,
//           day: dayNumber.toString(),
//           title: item['empName']?.toString() ?? '',
//           colorCode: item['dLsdate']?.toString() ?? '#FFFFFF',
//           checkIn: item['lsnote']?.toString() ?? '',
//           checkOut: item['lvpcarname']?.toString() ?? '',
//           workingHours: item['subname']?.toString() ?? '',
//           date: dateStr,
//           hasRequest: (item['lscont']?.toString() ?? '0') != '0',
//         ),
//       );
//     }
//
//     // Add to events map
//     final event = AttendanceEvent(
//       title: item['empName']?.toString() ?? '',
//       checkIn: item['lsnote']?.toString() ?? '',
//       checkOut: item['lvpcarname']?.toString() ?? '',
//       workingHours: item['subname']?.toString() ?? '',
//       colorCode: item['dLsdate']?.toString() ?? '#FFFFFF',
//       hasRequest: (item['lscont']?.toString() ?? '0') != '0',
//     );
//
//     _events[newDate] = (_events[newDate] ?? [])..add(event);
//   }
//
//   void _showErrorDialog(String message) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       showCupertinoModalPopup<void>(
//         context: context,
//         builder:
//             (context) => CupertinoAlertDialog(
//               title: const Text('Alert'),
//               content: Text(message, style: const TextStyle(fontSize: 14)),
//               actions: [
//                 CupertinoDialogAction(
//                   isDestructiveAction: true,
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('OK'),
//                 ),
//               ],
//             ),
//       );
//     });
//   }
//
//   Widget _buildTopRow() {
//     final user = ref.read(userDataProvider);
//     final now = DateTime.now();
//     final greeting =
//         now.hour < 12
//             ? "Good Morning"
//             : now.hour < 17
//             ? "Good Afternoon"
//             : "Good Evening";
//
//     return Container(
//       decoration: BoxDecoration(
//         image: const DecorationImage(
//           fit: BoxFit.cover,
//           image: AssetImage('assets/images/dashboardTopCard.png'),
//         ),
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
//           child: Row(
//             children: [
//               InkWell(
//                 onTap: () => scaffoldKey.currentState?.openDrawer(),
//                 borderRadius: BorderRadius.circular(15.r),
//                 child: Container(
//                   padding: EdgeInsets.all(12.w),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(15.r),
//                     border: Border.all(color: Colors.white.withOpacity(0.3)),
//                   ),
//                   child: Icon(Icons.menu, size: 24.sp, color: Colors.white),
//                 ),
//               ),
//               6.widthBox,
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     greeting,
//                     style: AppTextStyles.smallFont(color: Colors.white),
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     user?.empName ?? 'Employee',
//                     style: AppTextStyles.mediumFont(color: Colors.white),
//                   ),
//                 ],
//               ),
//               Spacer(),
//               if (widget.showCheckInOut)
//                 GestureDetector(
//                   onTap: () {
//                     ref.read(toggleCalendarProvider.notifier).state =
//                         !ref.watch(toggleCalendarProvider);
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(10.w),
//                     decoration: BoxDecoration(
//                       color:
//                           ref.watch(toggleCalendarProvider)
//                               ? Colors.white
//                               : Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Icon(
//                       CupertinoIcons.calendar,
//                       color:
//                           ref.watch(toggleCalendarProvider)
//                               ? AppTheme.primaryColor
//                               : Colors.white,
//                       size: 20.sp,
//                     ),
//                   ),
//                 ),
//               SizedBox(width: 12.w),
//               InkWell(
//                 onTap:
//                     () => NavigationService.navigateToScreen(
//                       context: context,
//                       screen: NotificationsScreen(),
//                     ),
//                 borderRadius: BorderRadius.circular(12.r),
//                 child: Container(
//                   padding: EdgeInsets.all(10.w),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Icon(
//                     CupertinoIcons.bell,
//                     color: Colors.white,
//                     size: 20.sp,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSummarySection() {
//     if (_summaryData.isEmpty && _requestStatuses.isEmpty)
//       return const SizedBox();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (_summaryData.isNotEmpty) ...[
//           SizedBox(
//             height: 120.h,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _summaryData.length,
//               itemBuilder: (context, index) {
//                 final summary = _summaryData[index];
//                 return _buildSummaryCard(summary);
//               },
//             ),
//           ),
//           SizedBox(height: 16.h),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildSummaryCard(AttendanceSummary summary) {
//     final color = Color(int.parse(summary.color.replaceAll('#', '0xFF')));
//
//     return Container(
//       width: 140.w,
//       margin: EdgeInsets.only(right: 12.w),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [color.withOpacity(0.8), color],
//         ),
//         borderRadius: BorderRadius.circular(20.r),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Text(
//               summary.shortCode,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 10.sp,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '${summary.count}',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 summary.name,
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.9),
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRequestStatusChip(RequestStatus status) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFF6B6B).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20.r),
//         border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 6.w,
//             height: 6.w,
//             decoration: const BoxDecoration(
//               color: Color(0xFFFF6B6B),
//               shape: BoxShape.circle,
//             ),
//           ),
//           SizedBox(width: 8.w),
//           Text(
//             '${status.name} (${status.count})',
//             style: TextStyle(
//               color: const Color(0xFFFF6B6B),
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       backgroundColor: const Color(0xFFF8FAFC),
//       drawerEdgeDragWidth: 75.w,
//       drawer: CustomDrawer(),
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(80.h),
//
//         child: _buildTopRow(),
//       ),
//
//       body: RefreshIndicator(
//         onRefresh: refreshCalendarData,
//         color: AppTheme.primaryColor,
//         child: Padding(
//           padding: AppPadding.screenPadding,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Summary Section
//                 _buildSummarySection(),
//
//                 // Calendar Section
//                 _buildCalendarSection(),
//                 // Request Status Cards
//                 if (_requestStatuses.isNotEmpty) ...[
//                   10.heightBox,
//                   Text(
//                     'Pending Requests',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   10.heightBox,
//                   Wrap(
//                     spacing: 12.w,
//                     runSpacing: 12.h,
//                     children:
//                         _requestStatuses.map(_buildRequestStatusChip).toList(),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCalendarSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Attendance Calendar',
//               style: TextStyle(
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             IconButton(
//               onPressed:
//                   () => setState(() {
//                     _calendarFormat =
//                         _calendarFormat == CalendarFormat.month
//                             ? CalendarFormat.twoWeeks
//                             : CalendarFormat.month;
//                   }),
//               icon: Icon(
//                 _calendarFormat == CalendarFormat.month
//                     ? CupertinoIcons.rectangle_grid_2x2
//                     : CupertinoIcons.rectangle_grid_1x2,
//                 color: AppTheme.primaryColor,
//                 size: 22.sp,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16.h),
//         _buildTableCalendar(),
//         if (_calendarDays.isNotEmpty) ...[
//           SizedBox(height: 20.h),
//           Text(
//             'Click Dates To Regularise',
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(height: 12.h),
//           _buildCalendarDaysRow(),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildTableCalendar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(16.r),
//       ),
//       child: TableCalendar<AttendanceEvent>(
//         calendarStyle: AppTheme.commonTableCalenderStyle,
//         headerStyle: HeaderStyle(
//           formatButtonVisible: false,
//           titleCentered: true,
//           titleTextStyle: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[800],
//           ),
//           leftChevronIcon: Icon(CupertinoIcons.chevron_left, size: 20.sp),
//           rightChevronIcon: Icon(CupertinoIcons.chevron_right, size: 20.sp),
//         ),
//         firstDay: _minDate,
//         lastDay: _maxDate,
//         focusedDay: _focusedDay,
//         calendarFormat: _calendarFormat,
//         rangeSelectionMode: _rangeSelectionMode,
//         eventLoader: _getEventsForDay,
//         startingDayOfWeek: StartingDayOfWeek.monday,
//         selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//         rangeStartDay: _rangeStart,
//         rangeEndDay: _rangeEnd,
//         onDaySelected: _onDaySelected,
//         onRangeSelected: _onRangeSelected,
//         onFormatChanged: (format) {
//           if (_calendarFormat != format) {
//             setState(() => _calendarFormat = format);
//           }
//         },
//         onPageChanged: (focusedDay) => _focusedDay = focusedDay,
//       ),
//     );
//   }
//
//   Widget _buildCalendarDaysRow() {
//     return SizedBox(
//       height: 100.h,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: _calendarDays.length,
//         itemBuilder: (context, index) {
//           final day = _calendarDays[index];
//           return _buildCalendarDayItem(day);
//         },
//       ),
//     );
//   }
//
//   Widget _buildCalendarDayItem(RegulariseCalendarDay day) {
//     final bgColor =
//         day.colorCode.isNotEmpty
//             ? Color(int.parse(day.colorCode.replaceAll('#', '0xFF')))
//             : const Color(0xFF6C5CE7);
//
//     return InkWell(
//       borderRadius: BorderRadius.circular(16.r),
//       onTap: () async {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => AttendanceRegularisationScreen(regulariseDay: day),
//           ),
//         ).then((_) {
//           refreshCalendarData();
//         });
//       },
//       child: Container(
//         width: 80.w,
//         margin: EdgeInsets.only(right: 12.w),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [bgColor.withOpacity(0.8), bgColor],
//           ),
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: bgColor.withOpacity(0.3),
//               blurRadius: 15,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (day.hasRequest)
//               Container(
//                 padding: EdgeInsets.all(6.w),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   CupertinoIcons.exclamationmark,
//                   color: Colors.white,
//                   size: 12.sp,
//                 ),
//               ),
//             SizedBox(height: 8.h),
//             Text(
//               day.day,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18.sp,
//                 color: Colors.white,
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               day.title.length > 8 ? day.title.substring(0, 8) : day.title,
//               style: TextStyle(
//                 fontSize: 10.sp,
//                 color: Colors.white.withOpacity(0.9),
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> refreshCalendarData() async {
//     if (_rangeStart != null) {
//       await _fetchAttendanceData(_rangeStart!, _rangeEnd ?? _rangeStart!);
//     } else if (_selectedDay != null) {
//       await _fetchAttendanceData(_selectedDay!, _selectedDay!);
//     }
//   }
// }

//TODO old
/*
class CalendarHomeView extends ConsumerStatefulWidget {
  final bool showCheckInOut;
  const CalendarHomeView({super.key, required this.showCheckInOut});

  @override
  ConsumerState<CalendarHomeView> createState() => _CalendarHomeViewState();
}

class _CalendarHomeViewState extends ConsumerState<CalendarHomeView>
    with WidgetsBindingObserver {
  // Constants
  static const _dojString =
      '30-06-2000 09:00:00'; //TODO give this as a date of joining
  static const _dateFormat = "dd-MM-yyyy HH:mm:ss";
  static const _maxFutureDays = 365;
  static const _requestTimeout = Duration(seconds: 60);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
    final now = DateTime.now();

    _selectedDay = now;

    // 👇 Initialize range from 1st of current month to today
    _rangeStart = DateTime(now.year, now.month, 1);
    _rangeEnd = now;

    _rangeSelectionMode = RangeSelectionMode.toggledOn;

    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    // Optionally fetch initial data for that range
    _fetchAttendanceData(_rangeStart!, _rangeEnd!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onRangeSelected(_rangeStart, _rangeEnd, _focusedDay);
    });
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

  Widget _buildTopRow() {
    final user = ref.read(userDataProvider);

    return ColoredBox(
      color: AppTheme.primaryColor,
      child: Row(
        children: [
          InkWell(
            onTap: () => scaffoldKey.currentState?.openDrawer(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(Icons.menu, size: 28.sp, color: Colors.black87),
            ),
          ),
          10.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "welcome".tr(),
                  style: AppTextStyles.smallFont(color: Colors.white),
                ),
                Text(
                  user?.empName ?? '',
                  style: AppTextStyles.mediumFont(color: Colors.white),
                ),
              ],
            ),
          ),
          if (widget.showCheckInOut)
            GestureDetector(
              onTap: () {
                ref.read(toggleCalendarProvider.notifier).state =
                    !ref.watch(toggleCalendarProvider);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      ref.watch(toggleCalendarProvider)
                          ? Colors.white
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.calendar,
                  color:
                      ref.watch(toggleCalendarProvider)
                          ? AppTheme.primaryColor
                          : Colors.white,
                ),
              ),
            ),
          IconButton(
            onPressed:
                () => NavigationService.navigateToScreen(
                  context: context,
                  screen: NotificationsScreen(),
                ),
            icon: const Icon(CupertinoIcons.bell),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userDataProvider);

    return Scaffold(
      key: scaffoldKey,
      drawerEdgeDragWidth: 75.w,
      extendBodyBehindAppBar: true,
      drawer: CustomDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h), // adjust height
        child: _buildTopRow(),
      ),
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
          // _buildCalendarHeader(),
          // SizedBox(height: 16.h),
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
*/
