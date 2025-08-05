import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/common/screens/leaveBalances_screen.dart';
import 'package:zeta_ess/services/secure_stroage_service.dart';

import '../../../../core/providers/language_provider.dart';
import '../../../auth/controller/localAuth_controller.dart';
import '../../../auth/screens/login_screen.dart';
import '../drawer_screens/announcement_screen.dart';
import '../drawer_screens/changePassword_screen.dart';
import '../drawer_screens/changePin_screen.dart';
import '../drawer_screens/downloads_screen.dart';
import '../drawer_screens/holiday_calendar_screen.dart';
import '../drawer_screens/paySlip_screen.dart';
import '../drawer_screens/suggestionFeedback_screen.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey languageTileKey = GlobalKey();
    context.locale;
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryColor, Color(0xFF0D47A1)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                10.heightBox,
                _buildDrawerItem(
                  Icons.history,
                  "suggestions_feedback".tr(),
                  screen: SuggestionFeedbackScreen(),
                  context: context,
                ),

                _buildDrawerItem(
                  Icons.calendar_month,
                  "Holiday Calendar".tr(),
                  screen: HolidayCalendar(),
                  context: context,
                ),
                _buildDrawerItem(
                  Icons.download_for_offline,
                  "downloads".tr(),
                  context: context,
                  screen: DownloadsScreen(),
                ),
                _buildDrawerItem(
                  Icons.campaign_sharp,
                  "announcements".tr(),
                  screen: AnnouncementsScreen(),
                  context: context,
                ),

                _buildDrawerItem(
                  Icons.payment,
                  "payslips".tr(),
                  screen: PayslipScreen(),
                  context: context,
                ),
                _buildDrawerItem(
                  Icons.pin,
                  "change_pin".tr(),
                  context: context,
                  screen: ChangePinScreen(),
                ),
                _buildDrawerItem(
                  CupertinoIcons.lock_fill,
                  "change_password".tr(),
                  context: context,
                  screen: ChangePasswordScreen(),
                ),

                _buildDrawerItem(
                  Icons.event_available,
                  "leave_balances".tr(),
                  context: context,
                  screen: LeaveBalancesScreen(title: "leave_balances"),
                ),

                // _buildDrawerItem(
                //   CupertinoIcons.globe,
                //   "change_language".tr(),
                //   onTap:
                //       () =>
                //           _showDropdownLikePopup(context, ref, languageTileKey),
                //   key: languageTileKey,
                // ),
                const Spacer(),
                _buildDrawerItem(
                  Icons.logout,
                  "logout".tr(),
                  isRed: true,
                  onTap: () {
                    showCustomAlertBox(
                      context,
                      title: 'Confirm Logout',
                      type: AlertType.warning,
                      secondaryButtonText: 'cancel'.tr(),
                      primaryButtonText: "logout".tr(),
                      onPrimaryPressed: () async {
                        //TODO check this clearly this can cause many issues in locally
                        await SecureStorageService.clearAll();
                        ref.invalidate(localAuthProvider);
                        NavigationService.navigateRemoveUntil(
                          context: context,
                          screen: const LoginScreen(),
                        );
                      },
                      content:
                          'Are you sure you want to log out of your account?',
                    );
                  },
                ),
                20.heightBox,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDropdownLikePopup(
    BuildContext context,
    WidgetRef ref,
    GlobalKey key,
  ) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RenderBox itemBox =
        key.currentContext?.findRenderObject() as RenderBox;

    final Offset position = itemBox.localToGlobal(Offset.zero);

    await showMenu<Locale>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + 100.w,
        position.dy,
        overlay.size.width - position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(value: Locale('en'), child: Text('English')),
        const PopupMenuItem(value: Locale('ar'), child: Text('العربية')),
        const PopupMenuItem(value: Locale('hi'), child: Text('हिन्दी')),
        const PopupMenuItem(value: Locale('ml'), child: Text('മലയാളം')),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ).then((selectedLocale) {
      if (selectedLocale != null) {
        ref.read(localeLanguageProvider.notifier).setLocale(selectedLocale);
        context.setLocale(selectedLocale);
      }
    });
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title, {
    bool isRed = false,
    Key? key,
    Widget? screen,
    BuildContext? context,
    VoidCallback? onTap,
  }) {
    return InkWell(
      key: key,
      onTap:
          onTap ??
          () {
            if (context != null && screen != null) {
              NavigationService.navigateToScreen(
                context: context,
                screen: screen,
              );
            }
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isRed ? Colors.red : Colors.white,
                size: 24.sp,
              ),
            ),
            20.widthBox,
            Flexible(
              child: Text(
                title,
                style: AppTextStyles.mediumFont(
                  color: isRed ? Colors.red : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
