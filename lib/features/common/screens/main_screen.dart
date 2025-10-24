import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loders/customScreen_loader.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/features/auth/screens/login_screen.dart';
import 'package:zeta_ess/features/common/screens/profile_screen.dart';
import 'package:zeta_ess/features/self_service/screens/selfService_screen.dart';

import '../../../services/version_helper.dart';
import '../../approval_management/screens/lineManagement_screen.dart';
import '../home/controller/version_check_controller.dart';
import '../home/home_screen.dart';
import '../models/version_check.dart';
import '../providers/common_ui_providers.dart';

final bottomNavProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    context.locale;

    final currentIndex = ref.watch(bottomNavProvider);
    final menuAsync = ref.watch(menuAgainstEmployeeProvider);

    return menuAsync.when(
      loading: () => CustomScreenLoader(loadingText: 'loading_menus'.tr()),
      error: (e, st) {
        return ErrorText(error: e.toString());
      },
      data: (menu) {
        //TODO this if check in is true then calendar should be false and vice versa
        Future.microtask(
          () =>
              ref.read(toggleCalendarProvider.notifier).state =
                  !menu.showCheckInOut,
        );

        final List<Widget> screens = [
          HomeScreen(
            showCheckInOut: menu.showCheckInOut,
            quickActions: menu.quickActions,
          ),
          if (menu.selfService) const SelfServicesScreen(),
          if (menu.lineManager) ApprovalManagementScreen(),
          const ProfileScreen(),
        ];

        final List<GButton> tabs = [
          _buildTab(CupertinoIcons.home, 'home'.tr()),
          if (menu.selfService)
            _buildTab(Icons.personal_injury, 'self_services'.tr()),
          if (menu.lineManager)
            _buildTab(CupertinoIcons.briefcase_fill, 'Approvals'.tr()),
          _buildTab(CupertinoIcons.person, 'profile'.tr()),
        ];
        if (screens.isEmpty || tabs.isEmpty) {
          return Center(child: Text("No menus available".tr()));
        }

        final safeIndex = currentIndex.clamp(0, screens.length - 1);

        return ShowCaseWidget(
          builder: (context) {
            return Scaffold(
              extendBody: false,
              body: screens[safeIndex],
              bottomNavigationBar: SafeArea(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 6.h,
                    ),
                    child: GNav(
                      tabMargin: EdgeInsets.symmetric(
                        vertical: 4.h,
                        horizontal: 10.w,
                      ),
                      selectedIndex: safeIndex,
                      onTabChange: (index) {
                        ref.read(bottomNavProvider.notifier).state = index;
                      },
                      tabBackgroundColor: AppTheme.primaryColor,
                      backgroundColor: Colors.transparent,
                      color: Colors.grey.shade600,
                      activeColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 12.h,
                      ),
                      tabBorderRadius: 12.r,
                      iconSize: 23.sp,
                      tabs: tabs,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  GButton _buildTab(IconData icon, String label) {
    return GButton(
      icon: icon,
      text: label,
      textStyle: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      gap: 8.w,
    );
  }
}
