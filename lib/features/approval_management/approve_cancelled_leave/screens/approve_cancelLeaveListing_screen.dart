import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/approval_management/approveLeave_management/controller/approve_leave_controller.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../../../self_service/leave_management/screens/leaveDetail_screen.dart';
import '../models/approve_leave_listing_model.dart';

class ApproveCancelLeaveListingScreen extends ConsumerWidget {
  final String title;
  const ApproveCancelLeaveListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveList = ref.watch(approveLeaveListProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(title.tr())),
        body: Column(
          children: [
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              tabs: approvalListTabs.map((tab) => Tab(text: tab.tr())).toList(),
              indicatorColor: Colors.blue,
            ),
            Expanded(
              child: leaveList.when(
                data: (data) {
                  return TabBarView(
                    children: [
                      LeaveListView(
                        leaveList: data.submitted,
                        isLineManager: true,
                      ),
                      LeaveListView(leaveList: data.approved),
                      LeaveListView(leaveList: data.rejected),
                    ],
                  );
                },
                error:
                    (error, stackTrace) => ErrorText(error: error.toString()),
                loading: () => Loader(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaveListView extends StatelessWidget {
  final List<LeaveApprovalListingModel> leaveList;
  final bool? isLineManager;
  const LeaveListView({super.key, required this.leaveList, this.isLineManager});

  @override
  Widget build(BuildContext context) {
    if (leaveList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.r),
      itemCount: leaveList.length,
      itemBuilder: (context, index) {
        final leave = leaveList[index];
        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: LeaveDetailsScreen(
                  isLineManager: isLineManager,
                  leaveId: leave.leaveId ?? '0',
                ),
              ),
          child: CustomTileListingWidget(
            text1: leave.leaveDays,
            subText1: "leaves".tr(),
            text2: leave.user ?? 'No name',
            subText2: "Date : ${leave.dateFrom}  To  ${leave.dateTo}",
          ),
        );
      },
    );
  }
}
