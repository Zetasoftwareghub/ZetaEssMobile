import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loders/customScreen_loader.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/common/screens/attendanceHistory_screen.dart';
import 'package:zeta_ess/features/common/screens/leaveBalances_screen.dart';
import 'package:zeta_ess/features/providers/employeeSelfLineMenu_provider.dart';
import 'package:zeta_ess/features/self_service/resumption_request/screens/resumptionListing_screen.dart';
import 'package:zeta_ess/features/self_service/screens/providers/selfServiceExpansionProvider.dart';
import 'package:zeta_ess/features/self_service/screens/widgets/customServiceListing_widget.dart';

import '../../../core/services/NavigationService.dart';
import '../attendance_regularisation/screens/attandanceRegularisation_datePick.dart';
import '../change_request/screens/change_request_listing_screen.dart';
import '../expense_claim/screens/expenseClaimListing_screen.dart';
import '../leave_management/screens/leaveListing_screen.dart';
import '../lieuDay_request/screens/lieuDayListing_screen.dart';
import '../loan/screens/loanListing_screen.dart';
import '../other_request/screens/other_request_first_listing_screen.dart';
import '../salary_advance/screens/salaryAdvanceListing_screen.dart';
import '../salary_certificate/screens/salaryCertificateListing_screen.dart';

class SelfServicesScreen extends ConsumerStatefulWidget {
  const SelfServicesScreen({super.key});

  @override
  ConsumerState<SelfServicesScreen> createState() => _SelfServicesScreenState();
}

class _SelfServicesScreenState extends ConsumerState<SelfServicesScreen> {
  final List<Color> indicatorColors = [
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.indigo,
    Colors.pink,
  ];

  final Map<String, Widget Function(String key)> selfServiceRoutes = {
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
    'change__request': (key) => ChangeRequestListingScreen(title: key),
    'salary_certificate_request':
        (key) => SalaryCertificateListingScreen(title: key),
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppPadding.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('self_services'.tr(), style: AppTextStyles.largeFont()),
            20.heightBox,
            Expanded(
              child: ref
                  .watch(employeeSelfLineMenusProvider)
                  .when(
                    data: (menus) {
                      return ListView(
                        children:
                            menus.selfService.entries.map((section) {
                              int colorIndex = 0;
                              final isExpanded =
                                  ref.watch(
                                    selfServiceExpansionProvider,
                                  )[section.key] ??
                                  false;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(
                                      bottom: isExpanded ? 12.h : 0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color:
                                            isExpanded
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.3)
                                                : Theme.of(
                                                  context,
                                                ).dividerColor.withOpacity(0.2),
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
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          if (section.key == 'other_requests') {
                                            NavigationService.navigateToScreen(
                                              context: context,
                                              screen:
                                                  OtherRequestFirstListingScreen(
                                                    title:
                                                        'other_requests'.tr(),
                                                  ),
                                            );
                                          } else {
                                            HapticFeedback.lightImpact();
                                            ref
                                                .read(
                                                  selfServiceExpansionProvider
                                                      .notifier,
                                                )
                                                .toggleSection(section.key);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        splashColor: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.1),
                                        highlightColor: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.05),
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
                                                    section.key.tr(),
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
                                                      duration: const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve:
                                                          Curves.easeInOutCubic,
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
                                                                        )
                                                                        .colorScheme
                                                                        .primary
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
                                    duration: const Duration(milliseconds: 400),
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
                                                          child:
                                                              Transform.translate(
                                                                offset: Offset(
                                                                  0,
                                                                  20 *
                                                                      (1 -
                                                                          value),
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
                                                          color: indicatorColor,
                                                          onTap: () {
                                                            final builder =
                                                                selfServiceRoutes[item
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
                        () => CustomScreenLoader(loadingText: 'loading_menus'),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
