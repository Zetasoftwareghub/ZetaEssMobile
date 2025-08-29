import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/approval_management/approve_change_request/models/approve_listing_model.dart';
import 'package:zeta_ess/features/self_service/change_request/screens/edit_change_request.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/services/NavigationService.dart';
import '../../../../core/utils/date_utils.dart';
import '../controller/notifier.dart';

class ApproveChangeRequestListing extends ConsumerWidget {
  final String title;
  const ApproveChangeRequestListing({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approveListAsync = ref.watch(approveChangeRequestListProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Column(
          children: [
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              tabs: approvalListTabs.map((tab) => Tab(text: tab.tr())).toList(),

              indicatorColor: Colors.blue,
            ),
            //TODO to approve request
            //ref.read(approveChangeRequestListProvider.notifier).approveRequest(requestCode);
            approveListAsync.when(
              data:
                  (data) => Expanded(
                    child: TabBarView(
                      children: [
                        ChangeRequestListView(
                          requestList: data.submitted,
                          isSubmittedTab: true,
                        ),
                        ChangeRequestListView(requestList: data.approved),
                        ChangeRequestListView(requestList: data.rejected),
                      ],
                    ),
                  ),
              loading: () => const Loader(),
              error: (error, stackTrace) => ErrorText(error: error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeRequestListView extends StatelessWidget {
  final List<ApproveChangeRequestListModel> requestList;
  final bool isSubmittedTab;
  const ChangeRequestListView({
    super.key,
    this.isSubmittedTab = false,
    required this.requestList,
  });

  @override
  Widget build(BuildContext context) {
    if (requestList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }
    return ListView.builder(
      padding: EdgeInsets.all(12.r),
      itemCount: requestList.length,
      itemBuilder: (context, index) {
        final request = requestList[index];

        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: EditChangeRequestScreen(
                  chrqcd: request.requestCode,
                  chrqst: request.chrqst,
                  employeeCode: request.employeeCode,
                  isLineManager: true,
                  isSubmittedTab: isSubmittedTab,
                ),
              ),
          child: CustomTileListingWidget(
            text1: convertRawDateToString(request.requestDate.toString()),
            text2: request.requestName,
            subText2: "Employee : ${request.employeeName}",
          ),
        );
      },
    );
  }
}
