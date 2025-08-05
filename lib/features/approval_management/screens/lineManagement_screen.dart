import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loders/customScreen_loader.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/approval_management/screens/providers/lineManagerExpansion_provider.dart';
import 'package:zeta_ess/features/providers/employeeSelfLineMenu_provider.dart';
import 'package:zeta_ess/features/self_service/screens/widgets/customServiceListing_widget.dart';

import '../../../core/services/NavigationService.dart';
import '../approveExpense_claim/screens/approve_expenseClaimListing_screen.dart';
import '../approveLeave_management/screens/approve_leaveListing_screen.dart';
import '../approveLieuDay_request/screens/approve_lieuDayListing_screen.dart';
import '../approve_attendance_regularisation/screens/approve_attendanceRegularisationListing_screen.dart';
import '../approve_loan/screens/approve_loanListing_screen.dart';
import '../approve_other_request/screens/approve_first_otherRequestListing_screen.dart';
import '../approve_resumption_request/screens/approve_resumptionListing_screen.dart';
import '../approve_salary_advance/screens/approve_salaryAdvanceListing_screen.dart';
import '../approve_salary_certificate/screens/approve_salaryCertificateListing_screen.dart';
import '../approve_schooling_allowance/screens/approve_schoolingAllowanceListing_screen.dart';

//TODO actually this and self service screens are 90% same
class ApprovalManagementScreen extends ConsumerWidget {
  ApprovalManagementScreen({super.key});

  final List<Color> indicatorColors = [
    AppTheme.primaryColor,
    Colors.orange,
    Colors.green,
    Colors.indigo,
    Colors.purple,
    Colors.red,
    Colors.pink,
  ];

  final Map<String, Widget Function(String key)> lineManagerRoutes = {
    'approve_leave': (key) => ApproveLeaveListingScreen(title: key),
    'resumption_approve': (key) => ApproveResumptionListingScreen(title: key),
    'lieu_day_approve': (key) => ApproveLieuDayListingScreen(title: key),
    'expense_claim_approve':
        (key) => ApproveExpenseClaimListingScreen(title: key),
    'salary_advance_approve':
        (key) => ApproveSalaryAdvanceListingScreen(title: key),
    'loan_approve': (key) => ApproveLoanListingScreen(title: key),
    'attendance_regularisation_approve':
        (key) => ApproveAttendanceRegularisationListingScreen(title: key),
    'schooling_allowance_approve':
        (key) => ApproveSchoolingAllowanceListingScreen(title: key),
    'salary_certificate_approve':
        (key) => ApproveSalaryCertificateListingScreen(title: key),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'approval_management'.tr(),
                style: AppTextStyles.largeFont(),
              ),
              10.heightBox,
              Text(
                "pending_approvals".tr(),
                style: AppTextStyles.mediumFont(fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: buildLineManagerTopTile(
                        icon: Icons.logout_sharp,
                        title: '${'approve'.tr()}\n${'leave'.tr()}',
                        value: '12',
                        height: 210.h,
                        bgImagePath: "assets/images/approvalOrangeCard.png",
                        firstColTile: true,
                      ),
                    ),
                    10.widthBox,
                    Flexible(
                      flex: 4,
                      child: Column(
                        children: [
                          buildLineManagerTopTile(
                            icon: Icons.group,
                            title: 'attendance'.tr(),
                            value: '1234',
                            height: 100.h,
                            bgImagePath: "assets/images/approvalBlueCard.png",
                          ),
                          10.heightBox,
                          buildLineManagerTopTile(
                            icon: Icons.money,
                            title: 'expenses'.tr(),
                            value: '1234',
                            height: 100.h,
                            bgImagePath: "assets/images/approvalYellowCard.png",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ref
                    .watch(employeeSelfLineMenusProvider)
                    .when(
                      data: (menus) {
                        final lineManagerMenus = menus.lineManager;
                        return ListView(
                          children:
                              lineManagerMenus.entries.map((section) {
                                int colorIndex = 0;
                                final isExpanded =
                                    ref.watch(
                                      lineManagerExpansionProvider,
                                    )[section.key] ??
                                    false;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: EdgeInsets.only(
                                        bottom: isExpanded ? 12.h : 0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color:
                                              isExpanded
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withOpacity(0.3)
                                                  : Theme.of(context)
                                                      .dividerColor
                                                      .withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                        color:
                                            isExpanded
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.05)
                                                : Theme.of(context).cardColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            if (section.key ==
                                                'other_requests') {
                                              NavigationService.navigateToScreen(
                                                context: context,
                                                screen:
                                                    ApproveOtherRequestFirstListingScreen(
                                                      title:
                                                          'other_requests'.tr(),
                                                    ),
                                              );
                                            } else {
                                              HapticFeedback.lightImpact();

                                              ref
                                                  .read(
                                                    lineManagerExpansionProvider
                                                        .notifier,
                                                  )
                                                  .toggleSection(section.key);
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          splashColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                          highlightColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.05),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 12.h,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: AnimatedDefaultTextStyle(
                                                    duration: const Duration(
                                                      milliseconds: 200,
                                                    ),
                                                    style:
                                                        AppTextStyles.mediumFont(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 18.sp,
                                                          color:
                                                              isExpanded
                                                                  ? Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary
                                                                  : Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                        ),
                                                    child: Text(
                                                      '${"approve".tr()} ${section.key.tr()}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                section.key == 'other_requests'
                                                    ? Icon(
                                                      CupertinoIcons
                                                          .arrow_right_circle,
                                                    )
                                                    : AnimatedContainer(
                                                      duration: const Duration(
                                                        milliseconds: 200,
                                                      ),
                                                      padding: EdgeInsets.all(
                                                        4.r,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            isExpanded
                                                                ? Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary
                                                                    .withOpacity(
                                                                      0.1,
                                                                    )
                                                                : Colors
                                                                    .transparent,
                                                      ),
                                                      child: TweenAnimationBuilder<
                                                        double
                                                      >(
                                                        tween: Tween<double>(
                                                          begin:
                                                              isExpanded
                                                                  ? 0
                                                                  : 0.5,
                                                          end:
                                                              isExpanded
                                                                  ? 0.5
                                                                  : 0,
                                                        ),
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 300,
                                                            ),
                                                        curve:
                                                            Curves
                                                                .easeInOutCubic,
                                                        builder: (
                                                          context,
                                                          value,
                                                          child,
                                                        ) {
                                                          return Transform.rotate(
                                                            angle:
                                                                value * 3.14159,
                                                            child: Icon(
                                                              Icons
                                                                  .keyboard_arrow_down_rounded,
                                                              size: 24.sp,
                                                              color:
                                                                  isExpanded
                                                                      ? Theme.of(
                                                                        context,
                                                                      ).colorScheme.primary
                                                                      : Theme.of(
                                                                            context,
                                                                          )
                                                                          .iconTheme
                                                                          .color
                                                                          ?.withOpacity(
                                                                            0.7,
                                                                          ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child:
                                          isExpanded
                                              ? Column(
                                                key: ValueKey(true),
                                                children:
                                                    section.value.map((item) {
                                                      Color
                                                      indicatorColor =
                                                          indicatorColors[colorIndex %
                                                              indicatorColors
                                                                  .length];
                                                      colorIndex++;

                                                      return TweenAnimationBuilder<
                                                        double
                                                      >(
                                                        duration: Duration(
                                                          milliseconds:
                                                              400 +
                                                              colorIndex * 100,
                                                        ),
                                                        tween: Tween<double>(
                                                          begin: 0,
                                                          end: 1,
                                                        ),
                                                        curve:
                                                            Curves.easeOutCubic,
                                                        builder: (
                                                          context,
                                                          value,
                                                          child,
                                                        ) {
                                                          return Opacity(
                                                            opacity: value,
                                                            child: Transform.translate(
                                                              offset: Offset(
                                                                0,
                                                                20 *
                                                                    (1 - value),
                                                              ),
                                                              child: child,
                                                            ),
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                bottom: 10.h,
                                                              ),
                                                          child: CustomServiceListingCard(
                                                            title:
                                                                item.menuName
                                                                    .tr(),
                                                            color:
                                                                indicatorColor,
                                                            onTap: () {
                                                              final builder =
                                                                  lineManagerRoutes[item
                                                                      .menuName];
                                                              if (builder !=
                                                                  null) {
                                                                NavigationService.navigateToScreen(
                                                                  context:
                                                                      context,
                                                                  screen: builder(
                                                                    item.menuName
                                                                        .tr(),
                                                                  ),
                                                                );
                                                              } else {
                                                                debugPrint(
                                                                  'No screen mapped for $item',
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                              )
                                              : const SizedBox.shrink(),
                                    ),
                                    SizedBox(height: 8.h),
                                  ],
                                );
                              }).toList(),
                        );
                      },
                      error:
                          (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                      loading:
                          () =>
                              CustomScreenLoader(loadingText: 'loading_menus'),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildLineManagerTopTile({
    required icon,
    required title,
    required value,

    required height,
    required bgImagePath,

    bool firstColTile = false,
  }) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(bgImagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (firstColTile) Icon(icon, color: Colors.white70),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!firstColTile) Icon(icon, color: Colors.white70),

              if (!firstColTile) SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.mediumFont(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.largeFont(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
