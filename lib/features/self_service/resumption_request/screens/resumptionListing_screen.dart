import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/features/self_service/resumption_request/controller/resumption_controller.dart';
import 'package:zeta_ess/features/self_service/resumption_request/screens/resumptionDetail_screen.dart';
import 'package:zeta_ess/features/self_service/resumption_request/screens/submitResumption_screen.dart';
import 'package:zeta_ess/models/listRights_model.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/services/NavigationService.dart';
import '../../../../core/utils.dart';
import '../models/resumption_listing_model.dart';
import '../providers/resumption_provider.dart';

class ResumptionListingScreen extends ConsumerWidget {
  final String title;

  const ResumptionListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumptionListState = ref.watch(resumptionListProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Column(
          children: [
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              tabs: listTabs.map((tab) => Tab(text: tab.tr())).toList(),

              indicatorColor: Colors.blue,
            ),
            resumptionListState.when(
              data: (data) {
                final submitted = data.submitted;
                final approved = data.approved;
                final rejected = data.rejected;

                return Expanded(
                  child: TabBarView(
                    children: [
                      ResumptionListView(
                        resumptionList: submitted.resumptionList,
                        listRightsModel: submitted.listRights,
                      ),
                      ResumptionListView(resumptionList: approved),
                      ResumptionListView(resumptionList: rejected),
                    ],
                  ),
                );
              },
              loading: () => Loader(),
              error: (e, _) => ErrorText(error: e.toString()),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: SubmitResumptionScreen(),
              ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class ResumptionListView extends ConsumerWidget {
  final List<ResumptionListingModel> resumptionList;
  final ListRightsModel? listRightsModel;
  const ResumptionListView({
    super.key,
    required this.resumptionList,
    this.listRightsModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return resumptionList.isEmpty
        ? Center(child: Text("No records found".tr()))
        : ListView.builder(
          padding: EdgeInsets.all(12.r).copyWith(bottom: 80.h),
          itemCount: resumptionList.length,
          itemBuilder: (context, index) {
            final resumption = resumptionList[index];
            return InkWell(
              onTap:
                  () => NavigationService.navigateToScreen(
                    context: context,
                    screen: ResumptionDetailsScreen(
                      resumptionId: resumption.reslno ?? 0,
                    ),
                  ),
              child: CustomTileListingWidget(
                text2: resumption.emname ?? 'no name',
                subText2: "Date : ${resumption.lsrdtt}",
                listRights: ListRightsModel(
                  canCreate: listRightsModel?.canCreate,
                  canDelete: listRightsModel?.canDelete,
                  canEdit: false,
                ),
                onView:
                    () => NavigationService.navigateToScreen(
                      context: context,
                      screen: ResumptionDetailsScreen(
                        resumptionId: resumption.reslno ?? 0,
                      ),
                    ),

                onDelete:
                    () => ref
                        .read(resumptionControllerProvider.notifier)
                        .deleteResumption(
                          resumptionId: resumption.reslno,
                          context: context,
                        ),
              ),
            );
          },
        );
  }
}
