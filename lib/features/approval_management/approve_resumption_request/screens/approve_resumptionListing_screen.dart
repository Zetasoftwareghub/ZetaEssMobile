import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/self_service/resumption_request/screens/resumptionDetail_screen.dart';

import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../controller/approve_resumption_controller.dart';
import '../models/approve_resumption_listing_model.dart';

class ApproveResumptionListingScreen extends ConsumerWidget {
  final String title;

  const ApproveResumptionListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumptionState = ref.watch(approveResumptionListProvider);

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
              child: resumptionState.when(
                data: (data) {
                  return TabBarView(
                    children: [
                      ResumptionListView(
                        resumptionList: data.submitted,
                        isLineManger: true,
                      ),
                      ResumptionListView(resumptionList: data.approved),
                      ResumptionListView(resumptionList: data.rejected),
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

class ResumptionListView extends StatelessWidget {
  final bool? isLineManger;

  final List<ApproveResumptionListingModel> resumptionList;
  const ResumptionListView({
    super.key,
    required this.resumptionList,
    this.isLineManger,
  });

  @override
  Widget build(BuildContext context) {
    if (resumptionList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }
    return ListView.builder(
      padding: EdgeInsets.all(12.r),
      itemCount: resumptionList.length,
      itemBuilder: (context, index) {
        final item = resumptionList[index];
        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: ResumptionDetailsScreen(
                  isLineManager: isLineManger,
                  resumptionId: item.reslno ?? 0,
                ),
              ),
          child: CustomTileListingWidget(
            text2: item.empname ?? 'No name',
            subText2: "Date : ${item.redate}",
          ),
        );
      },
    );
  }
}
