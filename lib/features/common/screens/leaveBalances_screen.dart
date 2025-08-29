import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';

import '../../../core/common/loders/customScreen_loader.dart';
import '../models/leaveBalance_model.dart';
import '../providers/common_ui_providers.dart';

class LeaveBalancesScreen extends ConsumerWidget {
  final String title;
  const LeaveBalancesScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveState = ref.watch(leaveBalanceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title.tr()), leading: const BackButton()),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: leaveState.when(
          data:
              (leaveList) =>
                  leaveList.isEmpty
                      ? Center(child: Text('noData'.tr()))
                      : ListView.builder(
                        itemCount: leaveList.length,
                        itemBuilder: (context, index) {
                          final leave = leaveList[index];
                          return LeaveCard(
                            title: leave.leaveName,
                            balanceList: leave.balTypeLst,
                            index: index,
                          );
                        },
                      ),
          loading:
              () => CustomScreenLoader(
                loadingText: 'loading_leave_balances'.tr(),
              ),
          error: (e, _) => Center(child: Text("${'error'.tr()}: $e")),
        ),
      ),
    );
  }
}

class LeaveCard extends StatefulWidget {
  final String title;
  final List<BalanceTypeModel> balanceList;
  final int index;

  const LeaveCard({
    super.key,
    required this.title,
    required this.balanceList,
    this.index = 0,
  });

  @override
  State<LeaveCard> createState() => _LeaveCardState();
}

class _LeaveCardState extends State<LeaveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start animation immediately without delay
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      color: AppTheme.primaryColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      widget.title.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children:
                    widget.balanceList
                        .asMap()
                        .entries
                        .map(
                          (entry) => _leaveStat(
                            entry.value.balType.tr(),
                            entry.value.balTypeVal,
                            entry.key,
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leaveStat(String label, String value, int index) {
    // Define gradient colors based on index
    final List<List<Color>> gradientColors = [
      [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)], // Purple
      [const Color(0xFF00B894), const Color(0xFF55EFC4)], // Green
      [const Color(0xFFE17055), const Color(0xFFFFAB7B)], // Orange
      [const Color(0xFF0984E3), const Color(0xFF74B9FF)], // Blue
      [const Color(0xFFE84393), const Color(0xFFFD79A8)], // Pink
      [const Color(0xFFFFB82E), const Color(0xFFFDCB6E)], // Yellow
    ];

    final colors = gradientColors[index % gradientColors.length];

    return _StatCard(
      label: label,
      value: value,
      gradientColors: colors,
      index: index,
    );
  }
}

class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final List<Color> gradientColors;
  final int index;

  const _StatCard({
    required this.label,
    required this.value,
    required this.gradientColors,
    required this.index,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 4.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) => _hoverController.reverse(),
      onTapCancel: () => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 85.w,
              height: 85.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.first.withOpacity(0.3),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: () {
                    // Add haptic feedback
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            widget.value,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//
// class LeaveBalancesScreen extends ConsumerWidget {
//   final String title;
//   const LeaveBalancesScreen({super.key, required this.title});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final leaveState = ref.watch(leaveBalanceProvider);
//
//     return Scaffold(
//       appBar: AppBar(title: Text(title.tr()), leading: const BackButton()),
//       body: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: leaveState.when(
//           data:
//               (leaveList) =>
//                   leaveList.isEmpty
//                       ? Center(child: Text('noData'.tr()))
//                       : ListView.builder(
//                         itemCount: leaveList.length,
//                         itemBuilder: (context, index) {
//                           final leave = leaveList[index];
//                           return LeaveCard(
//                             title: leave.leaveName,
//                             balanceList: leave.balTypeLst,
//                           );
//                         },
//                       ),
//           loading:
//               () => CustomScreenLoader(
//                 loadingText: 'loading_leave_balances'.tr(),
//               ),
//           error: (e, _) => Center(child: Text("${'error'.tr()}: $e")),
//         ),
//       ),
//     );
//   }
// }
//
// class LeaveCard extends StatelessWidget {
//   final String title;
//   final List<BalanceTypeModel> balanceList;
//
//   const LeaveCard({super.key, required this.title, required this.balanceList});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 8.h),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppTheme.primaryColor),
//         borderRadius: BorderRadius.circular(12.r),
//         color: Colors.white,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title.tr(),
//             style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 12.h),
//           Wrap(
//             spacing: 15.w,
//             runSpacing: 12.h,
//             children:
//                 balanceList
//                     .map((e) => _leaveStat(e.balType.tr(), e.balTypeVal))
//                     .toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _leaveStat(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Text(
//           value,
//           style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
//         ),
//         SizedBox(height: 4.h),
//         Text(
//           label,
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//         ),
//       ],
//     );
//   }
// }
