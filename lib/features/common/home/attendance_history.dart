// Attendance History Section
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/features/common/home/providers/punch_providers.dart';
import 'package:zeta_ess/features/common/home/widgets/todayPunch_widget.dart';

import '../../../../core/theme/common_theme.dart';

class AttendanceHistorySection extends StatelessWidget {
  final GlobalKey showcaseKey;

  const AttendanceHistorySection({super.key, required this.showcaseKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
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

          Text("attendance_history".tr(), style: AppTextStyles.mediumFont()),
          // Text("today_punc_history".tr(), style: AppTextStyles.mediumFont()),
          Spacer(),
          //TODO give this if you integrate the history!
          // CustomShowcaseWidget(
          //   showcaseKey: showcaseKey,
          //   title: "Attendance History",
          //   description: "Click here to view attendance history.",
          //   child: TextButton.icon(
          //     onPressed:
          //         () => NavigationService.navigateToScreen(
          //           context: context,
          //           screen: AttendanceHistoryScreen(),
          //         ),
          //     icon: const Icon(Icons.history),
          //     label: Text("view_all".tr()),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// Attendance List Section
class AttendanceListSection extends StatelessWidget {
  const AttendanceListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(bottom: 20.h),
      child: Consumer(
        builder: (context, ref, _) {
          final punchDetails = ref.watch(punchDetailsProvider);
          return punchDetails.when(
            loading: () => const Loader(),
            error: (error, _) => ErrorText(error: error.toString()),
            data: (punchList) {
              if (punchList.isEmpty) {
                return SizedBox(
                  height: 200.h,
                  child: Center(child: Text("No punch data available".tr())),
                );
              }

              return Column(
                children: List.generate(punchList.length, (index) {
                  print(punchList[index].punchType);

                  return TodayPunchWidget(punchModel: punchList[index]);
                }),
              );
            },
          );
        },
      ),
    );
  }
}
