import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/approval_management/approve_attendance_regularisation/models/approve_attendance_regularisation_listing_model.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../controller/approve_attendance_regularisation_controller.dart';
import 'approve_regularise_detail_screen.dart';

class ApproveAttendanceRegularisationListingScreen
    extends ConsumerStatefulWidget {
  final String title;

  const ApproveAttendanceRegularisationListingScreen({
    super.key,
    required this.title,
  });

  @override
  ConsumerState<ApproveAttendanceRegularisationListingScreen> createState() =>
      _ApproveAttendanceRegularisationListingScreenState();
}

class _ApproveAttendanceRegularisationListingScreenState
    extends ConsumerState<ApproveAttendanceRegularisationListingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(
      () => ref.invalidate(approveAttendanceRegularisationListProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regList = ref.watch(approveAttendanceRegularisationListProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: [
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              tabs: approvalListTabs.map((tab) => Tab(text: tab.tr())).toList(),

              indicatorColor: Colors.blue,
            ),
            Expanded(
              child: regList.when(
                data: (data) {
                  return TabBarView(
                    children: [
                      AttendanceRegulariseListView(
                        regList: data.submitted,
                        isApproveTab: true,
                      ),
                      AttendanceRegulariseListView(regList: data.approved),
                      AttendanceRegulariseListView(regList: data.rejected),
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

class AttendanceRegulariseListView extends StatelessWidget {
  final List<ApproveAttendanceRegularisationListingModel> regList;
  final bool? isApproveTab;
  const AttendanceRegulariseListView({
    super.key,
    required this.regList,
    this.isApproveTab,
  });

  @override
  Widget build(BuildContext context) {
    if (regList.isEmpty) {
      return Center(child: Text('No records found'.tr()));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.r),
      itemCount: regList.length,
      itemBuilder: (context, index) {
        final item = regList[index];
        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: AttendanceRegularizationApprove(
                  id: item.id.toString(),
                  isApproveTab: isApproveTab,
                ),
              ),
          child: CustomTileListingWidget(
            text1: item.empId.toString(),
            subText1: "ID",
            text2: item.employeeName ?? 'no name',
            subText2: "${'Date'.tr()} : ${item.regularisationDate}",
          ),
        );
      },
    );
  }
}
