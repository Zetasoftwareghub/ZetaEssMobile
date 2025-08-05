// Enhanced Quick Actions Widget
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/common/widgets/showCase_widget.dart';
import '../../../../../core/services/NavigationService.dart';
import '../../../../../core/theme/common_theme.dart';
import '../../../self_service/attendance_regularisation/screens/attandanceRegularisation_datePick.dart';
import '../../../self_service/expense_claim/screens/expenseClaimListing_screen.dart';
import '../../../self_service/leave_management/screens/leaveListing_screen.dart';
import '../../../self_service/lieuDay_request/screens/lieuDayListing_screen.dart';
import '../../../self_service/loan/screens/loanListing_screen.dart';
import '../../../self_service/other_request/screens/other_request_first_listing_screen.dart';
import '../../../self_service/resumption_request/screens/resumptionListing_screen.dart';
import '../../../self_service/salary_advance/screens/salaryAdvanceListing_screen.dart';
import '../../../self_service/salary_certificate/screens/salaryCertificateListing_screen.dart';
import '../../../self_service/schooling_allowance/screens/schoolingAllowanceListing_screen.dart';
import '../../screens/attendanceHistory_screen.dart';
import '../../screens/leaveBalances_screen.dart';

// Quick Actions Section
class QuickActionsSection extends StatelessWidget {
  final GlobalKey showcaseKey;
  final List<String> quickActionItems;
  const QuickActionsSection({
    required this.showcaseKey,
    required this.quickActionItems,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 24.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "quick_actions".tr(),
                style: AppTextStyles.mediumFont(color: Colors.grey.shade800),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Text(
                  "shortcuts".tr(),
                  style: AppTextStyles.mediumFont(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          QuickActionsWidget(
            showcaseKey: showcaseKey,
            quickActionItems: quickActionItems,
          ),
        ],
      ),
    );
  }
}

class QuickActionsWidget extends StatelessWidget {
  final GlobalKey showcaseKey;
  final List<String> quickActionItems;

  const QuickActionsWidget({
    super.key,
    required this.showcaseKey,
    required this.quickActionItems,
  });

  static final List<IconData> _icons = [
    Icons.send_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.event_note_rounded,
    Icons.calendar_today_rounded,
    Icons.check_circle_outline_rounded,
  ];

  static final List<List<Color>> _gradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFF11998e), Color(0xFF38ef7d)],
    [Color(0xFF6a11cb), Color(0xFF2575fc)],
    [Color(0xFFff9a9e), Color(0xFFfecfef)],
    [Color(0xFF00d2ff), Color(0xFF3a7bd5)],
  ];

  static final List<Color> _shadowColors = [
    Color(0xFF667eea),
    Color(0xFF11998e),
    Color(0xFF6a11cb),
    Color(0xFFff9a9e),
    Color(0xFF00d2ff),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 110.h,
        child: CustomShowcaseWidget(
          showcaseKey: showcaseKey,
          title: "Quick Actions",
          description: "Here you will get quick access to features.",
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: quickActionItems.length,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final title = quickActionItems[index];
              final colorIndex = index % _gradients.length;

              final action = {
                'title': title,
                'icon': _icons[colorIndex],
                'gradient': _gradients[colorIndex],
                'shadowColor': _shadowColors[colorIndex],
              };

              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutBack,
                child: _QuickActionItem(action: action, index: index),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Individual Quick Action Item
class _QuickActionItem extends StatefulWidget {
  final Map<String, dynamic> action;
  final int index;

  const _QuickActionItem({required this.action, required this.index});

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  bool _isPressed = false;

  final Map<String, Widget Function(String key)> quickActionTabs = {
    'submit_leave': (key) => LeaveListingScreen(title: key),
    'resumption_request': (key) => ResumptionListingScreen(title: key),
    'lieu_day_request': (key) => LieuDayListingScreen(title: key),
    'expense_claim_request': (key) => ExpenseClaimListingScreen(title: key),
    'salary_advance_requests': (key) => SalaryAdvanceListingScreen(title: key),
    'loan_request': (key) => LoanListingScreen(title: key),
    'leave_balances': (key) => LeaveBalancesScreen(title: key),
    'attendance_history': (key) => AttendanceHistoryScreen(),
    'other_requests': (key) => OtherRequestFirstListingScreen(title: key),
    'attendance_regularisation_request':
        (key) => AttendanceRegularisationDatePick(),
    // (key) => AttendanceRegularisationDatePick(title: key),
    'schooling_allowance_request':
        (key) => SchoolingAllowanceListingScreen(title: key),
    'salary_certificate_request':
        (key) => SalaryCertificateListingScreen(title: key),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _shadowAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 80.w,
            margin: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: () {
                final builder = quickActionTabs[widget.action['title']];
                if (builder != null) {
                  NavigationService.navigateToScreen(
                    context: context,
                    screen: builder(widget.action['title'].tr()),
                  );
                } else {
                  debugPrint('No screen mapped for ${widget.action['title']}');
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.action['gradient'],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.action['shadowColor'] as Color)
                          .withOpacity(0.3 * _shadowAnimation.value),
                      blurRadius: 20 * _shadowAnimation.value,
                      offset: Offset(0, 8 * _shadowAnimation.value),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.05 * _shadowAnimation.value,
                      ),
                      blurRadius: 10 * _shadowAnimation.value,
                      offset: Offset(0, 4 * _shadowAnimation.value),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient:
                        _isPressed
                            ? LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                            : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 8.w,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            widget.action['icon'],
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Flexible(
                          child: Text(
                            widget.action['title'],
                            style: AppTextStyles.mediumFont(
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
