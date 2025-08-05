import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/controller/salary_certificate_controller.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/models/salary_certificate_listing_model.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/screens/salrayCertificateDetails_screen.dart';
import 'package:zeta_ess/features/self_service/salary_certificate/screens/submitSalaryCertificate_screen.dart';
import 'package:zeta_ess/models/listRights_model.dart';

import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../providers/salary_certificate_notifiers.dart';

class SalaryCertificateListingScreen extends StatelessWidget {
  final String title;

  const SalaryCertificateListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
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
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(salaryCertificateListProvider);
                return Expanded(
                  child: state.when(
                    data:
                        (list) => TabBarView(
                          children: [
                            SalaryCertificateListView(
                              certificateList:
                                  list.submitted.salaryCertificateList,
                              listRightsModel: list.submitted.listRights,
                            ),
                            SalaryCertificateListView(
                              certificateList: list.approved,
                            ),
                            SalaryCertificateListView(
                              certificateList: list.rejected,
                            ),
                          ],
                        ),
                    error: (error, _) => ErrorText(error: error.toString()),
                    loading: () => const Loader(),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: SubmitSalaryCertificateScreen(),
              ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class SalaryCertificateListView extends ConsumerWidget {
  final List<SalaryCertificateListModel> certificateList;
  final ListRightsModel? listRightsModel;
  const SalaryCertificateListView({
    super.key,
    required this.certificateList,
    this.listRightsModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (certificateList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.r).copyWith(bottom: 80.h),
      itemCount: certificateList.length,
      itemBuilder: (context, index) {
        final certificate = certificateList[index];
        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: SalaryCertificateDetailsScreen(id: certificate.id),
              ),
          child: CustomTileListingWidget(
            text2: certificate.purpose ?? 'Empty',
            subText2:
                "Date From: ${certificate.fromMonth}  To: ${certificate.toMonth}",
            listRights: listRightsModel,
            onDelete:
                () => ref
                    .read(salaryCertificateControllerProvider.notifier)
                    .deleteSalaryCertificate(
                      context: context,
                      salaryCertificateId: int.parse(certificate.id ?? '0'),
                    ),
            onEdit:
                () => NavigationService.navigateToScreen(
                  context: context,
                  screen: SubmitSalaryCertificateScreen(
                    certificateId: certificate.id,
                  ),
                ),
            onView:
                () => NavigationService.navigateToScreen(
                  context: context,
                  screen: SalaryCertificateDetailsScreen(id: certificate.id),
                ),
          ),
        );
      },
    );
  }

  void navigateToDetail(String id, BuildContext context) {
    NavigationService.navigateToScreen(
      context: context,
      screen: SalaryCertificateDetailsScreen(id: id),
    );
  }
}
