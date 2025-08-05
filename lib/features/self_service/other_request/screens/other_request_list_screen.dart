import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/features/self_service/other_request/controller/other_request_controller.dart';
import 'package:zeta_ess/features/self_service/other_request/models/other_request_listing_model.dart';
import 'package:zeta_ess/features/self_service/other_request/screens/submitEdit_other_request.dart';

import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/services/NavigationService.dart';
import '../../../../core/utils.dart';
import '../../../../models/listRights_model.dart';
import '../controller/other_request_notifiers.dart';
import '../providers/other_request_providers.dart';
import 'other_request_detail_screen.dart';

class OtherRequestListingScreen extends ConsumerWidget {
  final String title;
  final String? requestId;
  final String? micode;

  // Create the parameter once
  late final OtherRequestParams _params;

  OtherRequestListingScreen({
    super.key,
    required this.title,
    required this.requestId,
    required this.micode,
  }) {
    _params = OtherRequestParams(requestId: requestId, micode: micode);
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(otherRequestListProvider(_params));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: listTabs.map((tab) => Tab(text: tab.tr())).toList(),
              indicatorColor: Colors.blue,
            ),
            Expanded(
              child: state.when(
                loading: () => const Loader(),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (data) {
                  return TabBarView(
                    children: [
                      OtherRequestListView(
                        list: data.submitted.requestList,
                        rightsModel: data.submitted.listRights,
                        micode: micode,
                        requestId: requestId,
                        menuName: title,
                      ),
                      OtherRequestListView(
                        list: data.approved,
                        micode: micode,
                        requestId: requestId,
                        menuName: title,
                      ),
                      OtherRequestListView(
                        list: data.rejected,
                        micode: micode,
                        requestId: requestId,
                        menuName: title,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            NavigationService.navigateToScreen(
              context: context,
              screen: SubmitEditOtherRequest(
                micode: micode,
                requestId: requestId,
                title: title,
                isEditMode: false,
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class OtherRequestListView extends ConsumerWidget {
  final List<OtherRequestListingModel> list;
  final ListRightsModel? rightsModel;
  final String? micode;
  final String? requestId;
  final String menuName;
  const OtherRequestListView({
    super.key,
    required this.list,
    this.rightsModel,
    this.micode,
    this.requestId,
    required this.menuName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (list.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.r).copyWith(bottom: 80.h),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];

        return InkWell(
          onTap: () {
            NavigationService.navigateToScreen(
              context: context,
              screen: OtherRequestDetailScreen(
                show: false,
                fromSelf: false,
                rqtmcd: requestId,
                rtencd: micode,
                menuName: menuName,
                // <-- your detail screen
                primaryKey: item.primaryKey ?? '0',
              ),
            );
          },
          child: CustomTileListingWidget(
            text1: '${'Submitted On'.tr()}\n${item.date ?? ''}',
            text2: item.name ?? "Unknown",
            subText2: "",
            listRights: rightsModel,
            onEdit: () {
              NavigationService.navigateToScreen(
                context: context,
                screen: SubmitEditOtherRequest(
                  // requestId: item.primaryKey,
                  title: menuName,
                  requestId: requestId,
                  micode: item.primaryKey,
                  isEditMode: true,
                ),
              );
            },
            onView: () {
              NavigationService.navigateToScreen(
                context: context,
                screen: OtherRequestDetailScreen(
                  show: false,
                  fromSelf: false,
                  rqtmcd: requestId,
                  rtencd: micode,
                  menuName: menuName,
                  primaryKey: item.primaryKey ?? '0',
                ),
              );
            },
            onDelete: () {
              ref
                  .read(otherRequestControllerProvider.notifier)
                  .deleteOtherRequest(
                    micode: micode,
                    primeKey: item.primaryKey,
                    context: context,
                  );
            },
          ),
        );
      },
    );
  }
}
