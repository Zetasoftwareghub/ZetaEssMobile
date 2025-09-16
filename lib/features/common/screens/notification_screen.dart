import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/features/approval_management/approveExpense_claim/screens/approve_expenseClaimListing_screen.dart';
import 'package:zeta_ess/features/approval_management/approveLeave_management/screens/approve_leaveListing_screen.dart';
import 'package:zeta_ess/features/approval_management/approveLieuDay_request/screens/approve_lieuDayListing_screen.dart';
import 'package:zeta_ess/features/approval_management/approve_attendance_regularisation/screens/approve_attendanceRegularisationListing_screen.dart';
import 'package:zeta_ess/features/approval_management/approve_change_request/screens/approve_change_request_listing.dart';
import 'package:zeta_ess/features/approval_management/approve_loan/screens/approve_loanListing_screen.dart';
import 'package:zeta_ess/features/approval_management/approve_other_request/screens/approve_first_otherRequestListing_screen.dart';
import 'package:zeta_ess/features/approval_management/approve_other_request/screens/approve_otherRequest_listing.dart';
import 'package:zeta_ess/features/approval_management/approve_resumption_request/screens/approve_resumptionListing_screen.dart';
import 'package:zeta_ess/features/approval_management/approve_salary_advance/screens/approve_salaryAdvanceListing_screen.dart';
import 'package:zeta_ess/features/approval_management/approve_salary_certificate/screens/approve_salaryCertificateListing_screen.dart';
import 'package:zeta_ess/features/self_service/attendance_regularisation/screens/attandanceRegularisation_datePick.dart';
import 'package:zeta_ess/features/self_service/change_request/screens/change_request_listing_screen.dart';
import 'package:zeta_ess/features/self_service/expense_claim/screens/expenseClaimListing_screen.dart';
import 'package:zeta_ess/features/self_service/leave_management/screens/leaveListing_screen.dart';
import 'package:zeta_ess/features/self_service/lieuDay_request/screens/lieuDayListing_screen.dart';
import 'package:zeta_ess/features/self_service/loan/screens/loanListing_screen.dart';
import 'package:zeta_ess/features/self_service/other_request/screens/other_request_first_listing_screen.dart';
import 'package:zeta_ess/features/self_service/resumption_request/screens/resumptionListing_screen.dart';
import 'package:zeta_ess/features/self_service/salary_advance/screens/salaryAdvanceListing_screen.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/screens/salaryCertificateListing_screen.dart';

import '../../../core/common/loders/customScreen_loader.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/screens/login_screen.dart';
import '../models/notification_model.dart';
import '../providers/common_ui_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force refresh when screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(menuAgainstEmployeeProvider);
      ref.refresh(getPendingRequestNotificationProvider);
      ref.refresh(getPendingApprovalsNotificationProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuAgainstEmployeeProvider);
    final pendingRequestAsync = ref.watch(
      getPendingRequestNotificationProvider,
    );
    final pendingApprovalsAsync = ref.watch(
      getPendingApprovalsNotificationProvider,
    );

    return menuAsync.when(
      loading: () => CustomScreenLoader(loadingText: 'loading_menus'.tr()),
      error: (e, st) => ErrorText(error: e.toString()),
      data: (menu) {
        final List<Tab> tabs = [];
        final List<Widget> tabViews = [];

        if (menu.selfService) {
          tabs.add(Tab(text: 'My Requests'.tr()));
          tabViews.add(
            _buildTabContent(
              pendingRequestAsync.when(
                data: (list) => _buildNotificationList(context, list, true),
                loading: () => Loader(),
                error: (e, _) => _buildErrorState(e.toString()),
              ),
            ),
          );
        }

        if (menu.lineManager) {
          tabs.add(Tab(text: 'My Approvals'.tr()));
          tabViews.add(
            _buildTabContent(
              pendingApprovalsAsync.when(
                data: (list) => _buildNotificationList(context, list, false),
                loading: () => Loader(),
                error: (e, _) => _buildErrorState(e.toString()),
              ),
            ),
          );
        }

        // If neither available, show empty screen or message
        if (tabs.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('Notifications'.tr())),
            body: Center(child: Text('No notification tabs available.'.tr())),
          );
        }

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: Text(
                'Notifications'.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black87),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60.h),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TabBar(
                    tabs: tabs,
                    indicator: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.all(4.w),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: TabBarView(children: tabViews),
              ),
            ),
          ),
        );
      },
    );
  }

  // @override
  Widget _buildTabContent(Widget child) {
    return Padding(padding: AppPadding.screenPadding, child: child);
  }

  Widget _buildErrorState(String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.red[50],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.error_outline, size: 48.sp, color: Colors.red[400]),
        ),
        SizedBox(height: 24.h),
        Text(
          'Something went wrong'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Please try again later'.tr(),
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    List<NotificationModel> notifications,
    bool isRequestTab,
  ) {
    if (notifications.isEmpty) {
      return _buildEmptyState(isRequestTab);
    }

    final validNotifications =
        notifications
            .where((model) => model.count != null && model.count != "0")
            .toList();

    if (validNotifications.isEmpty) {
      return _buildEmptyState(isRequestTab);
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: validNotifications.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final model = validNotifications[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutBack,
          child: GestureDetector(
            onTap: () => _handleNotificationTap(context, model, isRequestTab),
            child: _buildEnhancedNotificationTile(
              notify: model,
              context: context,
              isRequestTab: isRequestTab,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isRequestTab) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            "assets/images/emptyNotification.svg",
            height: 120.h,
            colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn),
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          isRequestTab
              ? 'No pending requests'.tr()
              : 'No pending approvals'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          isRequestTab
              ? 'All your requests are up to date'.tr()
              : 'No items waiting for your approval'.tr(),
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEnhancedNotificationTile({
    required NotificationModel notify,
    required BuildContext context,
    required bool isRequestTab,
  }) {
    final count = int.tryParse(notify.count ?? '0') ?? 0;
    final IconData icon = _getNotificationIcon(notify, isRequestTab);
    final Color iconColor = _getNotificationColor(notify, isRequestTab);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _handleNotificationTap(context, notify, isRequestTab),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, size: 24.sp, color: iconColor),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notify.name ?? 'No Message',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        isRequestTab
                            ? 'Your request'.tr()
                            : 'Needs approval'.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            count > 5
                                ? Colors.red[600]
                                : count > 2
                                ? Colors.orange[600]
                                : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14.sp,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationModel notify, bool isRequestTab) {
    if (isRequestTab) {
      switch (notify.id?.trim()) {
        case "152":
          return Icons.access_time_rounded;
        case "5":
          return Icons.beach_access_rounded;
        case "6":
          return Icons.description_rounded;
        case "7":
          return Icons.payments_rounded;
        case "8":
          return Icons.receipt_long_rounded;
        case "9999":
          return Icons.help_outline_rounded;
        case "112":
          return Icons.work_outline_rounded;
        case "84":
          return Icons.calendar_today_rounded;
        default:
          return Icons.notifications_rounded;
      }
    } else {
      final name = notify.name?.toLowerCase() ?? '';
      if (name.contains('leave')) return Icons.beach_access_rounded;
      if (name.contains('resumption')) return Icons.work_outline_rounded;
      if (name.contains('expense')) return Icons.receipt_long_rounded;
      if (name.contains('salary advance')) return Icons.payments_rounded;
      if (name.contains('salary certificate')) return Icons.description_rounded;
      if (name.contains('attendance')) return Icons.access_time_rounded;
      if (name.contains('lieu')) return Icons.calendar_today_rounded;
      return Icons.approval_rounded;
    }
  }

  Color _getNotificationColor(NotificationModel notify, bool isRequestTab) {
    if (isRequestTab) {
      return AppTheme.primaryColor!;
    } else {
      final name = notify.name?.toLowerCase() ?? '';
      if (name.contains('leave')) return Colors.green[600]!;
      if (name.contains('resumption')) return Colors.purple[600]!;
      if (name.contains('expense')) return Colors.orange[600]!;
      if (name.contains('salary')) return Colors.teal[600]!;
      if (name.contains('attendance')) return Colors.indigo[600]!;
      return AppTheme.primaryColor;
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel model,
    bool isRequestTab,
  ) {
    final id = model.id?.trim();
    final name = model.name?.trim();
    print(id);
    print('tapp');
    if (isRequestTab) {
      switch (id) {
        case "9":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: LoanListingScreen(title: 'loan_request'.tr()),
          );
          break;
        case "97":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: ChangeRequestListingScreen(title: 'change__request'.tr()),
          );
          break;
        case "152":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: AttendanceRegularisationDatePick(),
          );
          break;
        case "5":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: LeaveListingScreen(title: 'leave_requests'.tr()),
          );
          break;
        case "6":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: SalaryCertificateListingScreen(
              title: 'salary_certificate_requests'.tr(),
            ),
          );
          break;
        case "7":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: SalaryAdvanceListingScreen(
              title: 'salary_advance_requests'.tr(),
            ),
          );
          break;
        case "8":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: ExpenseClaimListingScreen(
              title: 'expense_claim_request'.tr(),
            ),
          );
          break;
        case "9999":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: OtherRequestFirstListingScreen(title: 'other_requests'),
          );
          break;
        case "112":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: ResumptionListingScreen(title: "resumption_requests".tr()),
          );
          break;
        case "84":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: LieuDayListingScreen(title: "lieu_days_requests".tr()),
          );
          break;
        default:
      }
    } else {
      switch (name) {
        case "Pending Approve Leave":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveLeaveListingScreen(title: 'approve_leave'),
          );
          break;
        case "Pending Approve Change Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: ApproveChangeRequestListing(
              title: 'change_request_approve'.tr(),
            ),
          );
          break;
        case "Pending Approve Loan Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: ApproveLoanListingScreen(title: 'loan_approve'),
          );
          break;
        case "Pending Approve Resumption":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: ApproveResumptionListingScreen(title: 'approve_resumption'),
          );
          break;
        case "Pending Approve Leave Cancellation Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: ApproveLeaveListingScreen(
              title: 'approve_leave_cancellation',
            ),
          );
          break;
        case "Pending Approve Expense Claim Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveExpenseClaimListingScreen(
              title: 'approve_expense_claims',
            ),
          );
          break;
        case "Pending Approve Salary Advance Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveSalaryAdvanceListingScreen(
              title: 'approve_salary_advance',
            ),
          );
          break;
        case "Pending Approve Salary Certificate Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveSalaryCertificateListingScreen(
              title: 'approve_salary_certificate',
            ),
          );
          break;
        case "Pending Approve Attendance Regularization Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveAttendanceRegularisationListingScreen(
              title: 'approve_attendance_regularization',
            ),
          );
          break;
        case "Pending Approve Other Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveOtherRequestFirstListingScreen(
              title: 'other_requests',
            ),
          );
          break;
        case "Pending Approve Lieu Days Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveLieuDayListingScreen(
              title: 'approve_lieu_days',
            ),
          );
          break;
        default:
      }
    }
  }
}

/*

//Working code before claude touch
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingRequestAsync = ref.watch(
      getPendingRequestNotificationProvider,
    );
    final pendingApprovalsAsync = ref.watch(
      getPendingApprovalsNotificationProvider,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text('Notifications'.tr())),
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'My Pending Request'.tr()),
                  Tab(text: 'My Pending Approvals'.tr()),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: AppPadding.screenPadding,
                  child: TabBarView(
                    children: [
                      pendingRequestAsync.when(
                        data:
                            (list) =>
                                _buildNotificationList(context, list, true),
                        loading: () => Loader(),
                        error: (e, _) => Center(child: Text("Error: $e")),
                      ),
                      pendingApprovalsAsync.when(
                        data:
                            (list) =>
                                _buildNotificationList(context, list, false),
                        loading: () => Loader(),
                        error: (e, _) => Center(child: Text("Error: $e")),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    List<NotificationModel> notifications,
    bool isRequestTab,
  ) {
    if (notifications.isEmpty) {
      return Center(
        child: SvgPicture.asset(
          "assets/images/emptyNotification.svg",
          height: 200.h,
        ),
      );
    }

    final validNotifications =
        notifications
            .where((model) => model.count != null && model.count != "0")
            .toList();

    return ListView.builder(
      itemCount: validNotifications.length,
      itemBuilder: (context, index) {
        final model = validNotifications[index];
        return GestureDetector(
          onTap: () => _handleNotificationTap(context, model, isRequestTab),
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildNotificationTile(notify: model),
          ),
        );
      },
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel model,
    bool isRequestTab,
  ) {
    final id = model.id?.trim();
    final name = model.name?.trim();

    if (isRequestTab) {
      switch (id) {
        case "152":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: AttendanceRegularisationDatePick(),
          );
          break;
        case "5":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: LeaveListingScreen(title: 'leave_requests'.tr()),
          );
          break;
        case "6":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: SalaryCertificateListingScreen(
              title: 'salary_certificate_requests'.tr(),
            ),
          );
          break;
        case "7":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: SalaryAdvanceListingScreen(
              title: 'salary_certificates_requests'.tr(),
            ),
          );
          break;
        case "8":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: ExpenseClaimListingScreen(
              title: 'expense_claim_requests'.tr(),
            ),
          );
          break;
        case "9999":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: OtherRequestFirstListingScreen(title: 'other_requests'),
          );
          break;
        case "112":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: ResumptionListingScreen(title: "resumption_requests".tr()),
          );
          break;
        case "84":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: LieuDayListingScreen(title: "lieu_days_requests".tr()),
          );
          break;
        default:
      }
    } else {
      switch (name) {
        case "Pending Approve Leave":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveLeaveListingScreen(title: 'approve_leave'),
          );
          break;
        case "Pending Approve Resumption":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: ApproveResumptionListingScreen(title: 'title'),
          );
          break;
        case "Pending Approve Leave Cancellation Request":
          NavigationService.navigatePushReplacement(
            context: context, //TODO this was cancel leave listing screen
            screen: ApproveLeaveListingScreen(title: 'title'),
          );
          break;
        case "Pending Approve Expense Claim Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveExpenseClaimListingScreen(title: 'title'),
          );
          break;
        case "Pending Approve Salary Advance Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveSalaryAdvanceListingScreen(title: 'title'),
          );
          break;
        case "Pending Approve Salary Certificate Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveSalaryCertificateListingScreen(title: 'title'),
          );
          break;
        case "Pending Approve Attendance Regularization Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveAttendanceRegularisationListingScreen(
              title: 'title',
            ),
          );
          break;
        case "Pending Approve Other Request":
          NavigationService.navigatePushReplacement(
            context: context, //TODO need req id micode passs karo
            screen: const ApproveOtherRequestListingScreen(
              title: 'title',
              micode: 'micode',
              requestId: 'requestId',
            ),
          );
          break;
        case "Pending Approve Lieu Days Request":
          NavigationService.navigatePushReplacement(
            context: context,
            screen: const ApproveLieuDayListingScreen(title: 'title'),
          );
          break;
        default:
      }
    }
  }

  Widget _buildNotificationTile({required NotificationModel notify}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.black87,
            child: Icon(Icons.chat_rounded, size: 20.sp, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              notify.name ?? 'No Message',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Text(notify.count ?? '0'),
        ],
      ),
    );
  }
}
*/
