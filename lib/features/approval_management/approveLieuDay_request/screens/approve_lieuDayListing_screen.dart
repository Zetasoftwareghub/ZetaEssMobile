import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/self_service/lieuDay_request/screens/lieuDayDetail_screen.dart';

import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../controller/approve_lieu_day_controller.dart';
import '../models/approve_lieu_day_listing_model.dart';

class ApproveLieuDayListingScreen extends ConsumerWidget {
  final String title;

  const ApproveLieuDayListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lieuDayState = ref.watch(approveLieuDayListProvider);

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
              child: lieuDayState.when(
                data: (data) {
                  return TabBarView(
                    children: [
                      LieuDayListView(
                        lieuDayList: data.submitted,
                        isLineManager: true,
                      ),
                      LieuDayListView(lieuDayList: data.approved),
                      LieuDayListView(lieuDayList: data.rejected),
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

class LieuDayListView extends StatelessWidget {
  final bool? isLineManager;
  final List<ApproveLieuDayListingModel> lieuDayList;
  const LieuDayListView({
    super.key,
    required this.lieuDayList,
    this.isLineManager,
  });

  @override
  Widget build(BuildContext context) {
    if (lieuDayList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }
    return ListView.builder(
      padding: EdgeInsets.all(12.r),
      itemCount: lieuDayList.length,
      itemBuilder: (context, index) {
        final item = lieuDayList[index];
        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: LieuDayDetailScreen(
                  isLineManager: isLineManager ?? false,
                  lieuDayId: item.lieuDayId?.toString() ?? '',
                ),
              ),
          child: CustomTileListingWidget(
            text2: item.employeeName ?? 'No name',
            subText2: "${'Date'.tr()} : ${item.lieuDayDate ?? ''}",
          ),
        );
      },
    );
  }
}
