import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';
import 'package:zeta_ess/features/self_service/change_request/controller/change_request_controller.dart';
import 'package:zeta_ess/features/self_service/change_request/models/change_request_list_response.dart';
import 'package:zeta_ess/features/self_service/change_request/screens/edit_change_request.dart';
import 'package:zeta_ess/features/self_service/change_request/screens/submit_change_request.dart';
import 'package:zeta_ess/models/listRights_model.dart';

import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../providers/change_request_providers.dart';
import 'change_request_details.dart';

class ChangeRequestListingScreen extends ConsumerWidget {
  final String title;

  const ChangeRequestListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(changeRequestNotifierProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(title.tr())),
        body: Column(
          children: [
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              tabs: listTabs.map((tab) => Tab(text: tab.tr())).toList(),

              indicatorColor: Colors.blue,
            ),
            requestAsync.when(
              data:
                  (data) => Expanded(
                    child: TabBarView(
                      children: [
                        ChangeRequestListView(
                          requestList: data.submittedModel.submitted,
                          rights: data.submittedModel.rights,
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            NavigationService.navigateToScreen(
              context: context,
              screen: SubmitChangeRequestScreen(),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class ChangeRequestListView extends ConsumerWidget {
  final List<ChangeRequestListModel> requestList;
  final ListRightsModel? rights;
  const ChangeRequestListView({
    super.key,
    required this.requestList,
    this.rights,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (requestList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }
    return ListView.builder(
      padding: EdgeInsets.all(12.r).copyWith(bottom: 80.h),
      itemCount: requestList.length,
      itemBuilder: (context, index) {
        final request = requestList[index];
        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: ChangeRequestDetailsScreen(
                  reqId: request.chrqcd,
                  title: request.requestType,
                ),
              ),
          child: CustomTileListingWidget(
            listRights: rights,
            text1: convertRawDateToString(request.date),
            text2: request.requestType,
            subText2:
                request.status.isEmpty ? "" : "Status : ${request.status}",
            onEdit: () {
              NavigationService.navigateToScreen(
                // screen: EditChangeRequestScreen(requestModel: request),
                screen: EditChangeRequestScreen(
                  chrqcd: request.chrqcd,
                  chrqst: request.chrqtp,
                ),
                context: context,
              );
            },
            onView:
                () => NavigationService.navigateToScreen(
                  context: context,
                  screen: ChangeRequestDetailsScreen(
                    reqId: request.chrqcd,
                    title: request.requestType,
                  ),
                ),
            onDelete: () {
              ref
                  .read(changeRequestControllerProvider.notifier)
                  .deleteChangeRequest(
                    context: context,
                    changeRequestId: request.chrqcd,
                  );
            },
          ),
        );
      },
    );
  }
}
