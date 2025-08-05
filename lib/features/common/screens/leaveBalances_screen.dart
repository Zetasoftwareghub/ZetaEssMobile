import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

class LeaveCard extends StatelessWidget {
  final String title;
  final List<BalanceTypeModel> balanceList;

  const LeaveCard({super.key, required this.title, required this.balanceList});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor),
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.tr(),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 15.w,
            runSpacing: 12.h,
            children:
                balanceList
                    .map((e) => _leaveStat(e.balType.tr(), e.balTypeVal))
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _leaveStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ],
    );
  }
}
