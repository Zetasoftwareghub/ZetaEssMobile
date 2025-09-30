import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/approval_management/approve_salary_certificate/models/approve_salary_certificate_listing_model.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/screens/salrayCertificateDetails_screen.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../controller/approve_salary_certificate_controller.dart';

class ApproveSalaryCertificateListingScreen extends ConsumerWidget {
  final String title;

  const ApproveSalaryCertificateListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificateList = ref.watch(approveSalaryCertificateListProvider);
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
              child: certificateList.when(
                data: (data) {
                  return TabBarView(
                    children: [
                      SalaryCertificateListView(
                        certificateList: data.submitted,
                        isLineManger: true,
                      ),
                      SalaryCertificateListView(certificateList: data.approved),
                      SalaryCertificateListView(certificateList: data.rejected),
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

class SalaryCertificateListView extends StatelessWidget {
  final bool? isLineManger;
  final List<ApproveSalaryCertificateListingModel> certificateList;
  const SalaryCertificateListView({
    super.key,
    required this.certificateList,
    this.isLineManger,
  });

  @override
  Widget build(BuildContext context) {
    if (certificateList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }
    return ListView.builder(
      padding: EdgeInsets.all(12.r),
      itemCount: certificateList.length,
      itemBuilder: (context, index) {
        final item = certificateList[index];
        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: SalaryCertificateDetailsScreen(
                  isLineManager: isLineManger ?? false,
                  id: item.id,
                ),
              ),
          child: CustomTileListingWidget(
            text2: item.name ?? 'No name',
            subText2:
                "${'Date'.tr()}: ${item.dateFrom}  ${'To'.tr()}: ${item.dateTo}",
          ),
        );
      },
    );
  }
}
