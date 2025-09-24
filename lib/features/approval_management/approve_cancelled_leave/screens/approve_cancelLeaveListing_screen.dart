import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/features/approval_management/approve_cancelled_leave/models/cancel_leave_listing.dart';
import 'package:zeta_ess/features/approval_management/approve_cancelled_leave/screens/cancel_leave_detail.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/services/NavigationService.dart';
import '../../../../core/utils.dart';
import '../controller/approve_cacncel_leave_controller.dart';

class ApproveCancelLeaveListingScreen extends ConsumerWidget {
  final String title;
  const ApproveCancelLeaveListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveList = ref.watch(approveCancelLeaveListProvider);
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
                        showCommentField: true,
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
  final List<ApproveCancelLeaveListingModel> leaveList;
  final bool? showCommentField;
  const LeaveListView({
    super.key,
    required this.leaveList,
    this.showCommentField,
  });

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
          onTap: () {
            NavigationService.navigateToScreen(
              context: context,
              screen: CancelLeaveDetailsScreen(
                showCommentField: showCommentField ?? false,
                clslno: leave.clslno,
                laslno: leave.laslno,
                lsslno: leave.lsslno,
              ),
            );
          },
          child: CustomTileListingWidget(
            text2: leave.employeeName,
            subText2: "Date : ${leave.leaveDateFrom}  To  ${leave.leaveDateTo}",
          ),
        );
      },
    );
  }
}
