import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/leave_management/controller/leave_controller.dart';
import 'package:zeta_ess/features/self_service/leave_management/providers/leave_providers.dart';
import 'package:zeta_ess/features/self_service/leave_management/screens/submitLeave_screen.dart';
import 'package:zeta_ess/models/listRights_model.dart';

import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../models/leave_model.dart';
import 'leaveDetail_screen.dart';

class LeaveListingScreen extends ConsumerStatefulWidget {
  final String title;
  const LeaveListingScreen({super.key, required this.title});

  @override
  ConsumerState<LeaveListingScreen> createState() => _LeaveListingScreenState();
}

class _LeaveListingScreenState extends ConsumerState<LeaveListingScreen> {
  final tabs = ["submitted", "approved", "rejected", "cancelled"];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: [
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              indicatorColor: Colors.blue,
              tabs: tabs.map((tab) => Tab(text: tab.tr())).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // 🔹 Submitted Leaves
                  ref
                      .watch(submittedLeaveListProvider)
                      .when(
                        data:
                            (leaveResponse) => LeaveListView(
                              leaveList: leaveResponse.leaves,
                              listRights: leaveResponse.listRights,
                            ),
                        error: (error, _) => ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      ),

                  // 🔹 Approved
                  _buildLeaveTab(
                    ref: ref,
                    provider: approvedLeavesProvider,
                    showCancelLeave: true,
                  ),

                  // 🔹 Rejected
                  _buildLeaveTab(ref: ref, provider: rejectedLeavesProvider),

                  // 🔹 Cancelled
                  _buildLeaveTab(ref: ref, provider: cancelledLeavesProvider),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            NavigationService.navigateToScreen(
              context: context,
              screen: SubmitLeaveScreen(),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildLeaveTab({
    bool? showCancelLeave,
    required WidgetRef ref,
    required AutoDisposeAsyncNotifierProvider<
      AutoDisposeAsyncNotifier<List<LeaveModel>>,
      List<LeaveModel>
    >
    provider,
  }) {
    final state = ref.watch(provider);

    return state.when(
      data: (leaves) {
        return LeaveListView(
          leaveList: leaves,
          showCancelLeave: showCancelLeave,
        );
      },
      error: (e, _) => ErrorText(error: e.toString()),
      loading: () => const Loader(),
    );
  }
}

class LeaveListView extends StatelessWidget {
  final List<LeaveModel> leaveList;
  final ListRightsModel? listRights;
  final bool? showCancelLeave;
  const LeaveListView({
    super.key,
    required this.leaveList,
    this.listRights,
    this.showCancelLeave,
  });

  @override
  Widget build(BuildContext context) {
    return leaveList.isEmpty
        ? Center(child: Text("No records found".tr()))
        : ListView.builder(
          padding: EdgeInsets.all(12.r).copyWith(bottom: 80.h),
          itemCount: leaveList.length,
          itemBuilder: (context, index) {
            final leave = leaveList[index];
            return InkWell(
              onTap:
                  () => NavigationService.navigateToScreen(
                    context: context,
                    screen: LeaveDetailsScreen(
                      leaveId: leave.leaveId ?? '',
                      showCancelLeave: showCancelLeave,
                      isSelf: true,
                    ),
                  ),
              child: Consumer(
                builder: (context, ref, child) {
                  return CustomTileListingWidget(
                    text1: leave.leaveDays,
                    subText1: "leaves".tr(),
                    text2: leave.leaveType ?? 'No Name',
                    subText2:
                        "${'Date'.tr()} : ${leave.leaveFrom}  ${'To'.tr()}: ${leave.leaveTo}",
                    listRights: listRights,
                    onView:
                        () => NavigationService.navigateToScreen(
                          context: context,
                          screen: LeaveDetailsScreen(
                            leaveId: leave.leaveId ?? '',
                            isSelf: true,
                            showCancelLeave: showCancelLeave,
                          ),
                        ),
                    onEdit:
                        () => NavigationService.navigateToScreen(
                          context: context,
                          screen: SubmitLeaveScreen(
                            leaveId: leave.leaveId ?? '0',
                          ),
                        ),
                    onDelete:
                        () => ref
                            .read(leaveControllerProvider.notifier)
                            .deleteLeave(
                              context: context,
                              leaveId: int.parse(leave.leaveId ?? '0'),
                            ),
                  );
                },
              ),
            );
          },
        );
  }
}
