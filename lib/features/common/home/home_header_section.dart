import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/common/widgets/showCase_widget.dart';
import '../../../../core/services/NavigationService.dart';
import '../../../../core/theme/common_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../screens/notification_screen.dart';
import 'calender_home_view.dart';
import 'home_screen.dart';
import 'punch_home_view.dart';

class HeaderSection extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ShowcaseKeys showcaseKeys;
  final bool showCheckInOut;
  final bool isCheckIn;

  const HeaderSection({
    super.key,
    required this.scaffoldKey,
    required this.showcaseKeys,
    required this.showCheckInOut,
    required this.isCheckIn,
  });

  @override
  ConsumerState<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends ConsumerState<HeaderSection> {
  @override
  Widget build(BuildContext context) {
    final showCalendar = ref.watch(toggleCalendarProvider);
    return SizedBox(
      height: widget.showCheckInOut ? 420.h : 580.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBackgroundHeader(),
          widget.showCheckInOut
              ? showCalendar
                  ? CalendarHomeView()
                  : PunchHomeView(showcaseKeys: widget.showcaseKeys)
              : CalendarHomeView(),
        ],
      ),
    );
  }

  Widget _buildBackgroundHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18.w),
          bottomRight: Radius.circular(18.w),
        ),
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/dashboardTopCard.png'),
        ),
      ),
      height: 200.h,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          20.heightBox,
          _buildTopRow(),
          20.heightBox,
          if (widget.showCheckInOut && !ref.watch(toggleCalendarProvider))
            _buildTodayAttendanceRow(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    final user = ref.read(userDataProvider);
    return Row(
      children: [
        InkWell(
          onTap: () => widget.scaffoldKey.currentState?.openDrawer(),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: CustomShowcaseWidget(
              showcaseKey: widget.showcaseKeys.menuKey,
              title: "Navigation Menu",
              description:
                  "Open the drawer to access actions like Downloads, Payslips, Change Password, Change Pin, Change Language Suggestions and feedbacks and Logout.",
              child: Icon(Icons.menu, size: 28.sp, color: Colors.black87),
            ),
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
          icon: CustomShowcaseWidget(
            showcaseKey: widget.showcaseKeys.notificationKey,
            title: "Notification Panel",
            description: "Tap here to see notifications.",

            child: const Icon(CupertinoIcons.bell),
          ),
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildTodayAttendanceRow() {
    return Row(
      children: [
        Text(
          "today_attendance".tr(),
          style: AppTextStyles.smallFont(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          formatDate(DateTime.now()),
          style: AppTextStyles.smallFont(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
