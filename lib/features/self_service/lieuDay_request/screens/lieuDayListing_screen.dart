import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/self_service/lieuDay_request/controller/lieuday_controller.dart';
import 'package:zeta_ess/features/self_service/lieuDay_request/screens/submitLieuDay_screen.dart';

import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../../../../models/listRights_model.dart';
import '../models/lieuDay_listing_model.dart';
import '../providers/lieuDay_provider.dart';
import 'lieuDayDetail_screen.dart';

class LieuDayListingScreen extends ConsumerWidget {
  final String title;

  const LieuDayListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lieuDayListProvider);

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
            Expanded(
              child: state.when(
                loading: () => const Loader(),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (data) {
                  return TabBarView(
                    children: [
                      LieuDayListView(
                        list: data.submitted.lieuDayList,
                        rightsModel: data.submitted.listRights,
                      ),
                      LieuDayListView(list: data.approved),
                      LieuDayListView(list: data.rejected),
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
              screen: const SubmitLieuDayScreen(),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class LieuDayListView extends ConsumerWidget {
  final List<LieuDayListingModel> list;
  final ListRightsModel? rightsModel;
  const LieuDayListView({super.key, required this.list, this.rightsModel});

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
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: LieuDayDetailScreen(lieuDayId: item.rqldcode ?? '0'),
              ),
          child: CustomTileListingWidget(
            text1: item.ludate ?? '',

            text2: item.lulvtp ?? "Unknown",
            subText2: "Status: ${item.apstat}",
            listRights: rightsModel,
            onDelete:
                () => ref
                    .read(lieuDayControllerProvider.notifier)
                    .deleteLieuDay(
                      lieuDayId: int.parse(item.rqldcode ?? '0'),
                      context: context,
                    ),
            onEdit:
                () => NavigationService.navigateToScreen(
                  context: context,
                  screen: SubmitLieuDayScreen(lieuDayId: item.rqldcode ?? '0'),
                ),
            onView:
                () => NavigationService.navigateToScreen(
                  context: context,
                  screen: LieuDayDetailScreen(lieuDayId: item.rqldcode ?? '0'),
                ),
          ),
        );
      },
    );
  }
}
