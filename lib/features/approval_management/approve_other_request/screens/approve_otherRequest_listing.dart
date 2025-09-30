import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/features/approval_management/approve_other_request/models/approve_listing_model.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/services/NavigationService.dart';
import '../../../../core/utils.dart';
import '../../../self_service/other_request/screens/other_request_detail_screen.dart';
import '../controller/approve_otherRequest_notifiers.dart';

class ApproveOtherRequestListingScreen extends ConsumerWidget {
  final String title, micode, requestId;
  const ApproveOtherRequestListingScreen({
    super.key,
    required this.title,
    required this.micode,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherRequestList = ref.watch(
      approveOtherRequestListProvider(
        ApproveOtherRequestParams(requestId: requestId, micode: micode),
      ),
    );

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
            Expanded(
              child: otherRequestList.when(
                data: (data) {
                  return TabBarView(
                    children: [
                      OtherRequestListView(
                        otherRequestList: data.submitted,
                        isLineManager: true,
                        menuId: requestId,
                        micode: micode,
                      ),
                      OtherRequestListView(
                        otherRequestList: data.approved,
                        menuId: requestId,
                        micode: micode,
                      ),
                      OtherRequestListView(
                        otherRequestList: data.rejected,
                        menuId: requestId,
                        micode: micode,
                      ),
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

class OtherRequestListView extends StatelessWidget {
  final List<ApproveOtherRequestListingModel> otherRequestList;
  final bool? isLineManager;
  final String micode, menuId;
  const OtherRequestListView({
    super.key,
    required this.otherRequestList,
    this.isLineManager,
    required this.micode,
    required this.menuId,
  });

  @override
  Widget build(BuildContext context) {
    if (otherRequestList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.r),
      itemCount: otherRequestList.length,
      itemBuilder: (context, index) {
        final otherRequest = otherRequestList[index];
        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: OtherRequestDetailScreen(
                  fromSelf: false,
                  show: isLineManager ?? false,
                  rqtmcd: otherRequest.rqtmcd.toString(),
                  rtencd: micode,
                  primaryKey: otherRequest.primaryKey,
                  menuName: otherRequest.requestName,
                  menuId: micode,
                ),
              ),
          child: CustomTileListingWidget(
            text1:
                '${'Submitted On'.tr()}\n${otherRequest.date?.split(' ')[0] ?? ''}',
            // text2: otherRequest.name ?? "Unknown",
            text2: otherRequest.name ?? 'No name',
            subText2: otherRequest.requestName ?? 'Request',
          ),
        );
      },
    );
  }
}
