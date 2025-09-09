import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/self_service/salary_advance/controller/salary_advance_controller.dart';
import 'package:zeta_ess/features/self_service/salary_advance/models/salaryAdvance_listing_model.dart';
import 'package:zeta_ess/features/self_service/salary_advance/screens/salaryAdvanceDetail_screen.dart';
import 'package:zeta_ess/features/self_service/salary_advance/screens/submitSalaryAdvance_screen.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../../../../models/listRights_model.dart';
import '../providers/salaryAdvance_provider.dart';

class SalaryAdvanceListingScreen extends ConsumerStatefulWidget {
  final String title;

  const SalaryAdvanceListingScreen({super.key, required this.title});

  @override
  ConsumerState<SalaryAdvanceListingScreen> createState() =>
      _SalaryAdvanceListingScreenState();
}

class _SalaryAdvanceListingScreenState
    extends ConsumerState<SalaryAdvanceListingScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salaryAdvanceListProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: [
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              indicatorColor: Colors.blue,
              tabs: listTabs.map((tab) => Tab(text: tab.tr())).toList(),
            ),
            Expanded(
              child: state.when(
                data: (data) {
                  return TabBarView(
                    children: [
                      SalaryAdvanceListView(
                        items: data.submitted.salaryAdvanceList,
                        listRights: data.submitted.listRights,
                      ),
                      SalaryAdvanceListView(
                        items: data.approved,
                        showApproveAmount: true,
                      ),
                      SalaryAdvanceListView(items: data.rejected),
                    ],
                  );
                },
                loading: () => const Loader(),
                error: (e, _) => ErrorText(error: e.toString()),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            NavigationService.navigateToScreen(
              context: context,
              screen: SubmitSalaryAdvanceScreen(),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class SalaryAdvanceListView extends ConsumerWidget {
  final List<SalaryAdvanceListingModel> items;
  final ListRightsModel? listRights;
  final bool showApproveAmount;

  const SalaryAdvanceListView({
    super.key,
    required this.items,
    this.listRights,
    this.showApproveAmount = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.r).copyWith(bottom: 80.h),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return InkWell(
          onTap:
              () =>
                  navigateToDetail(item.id ?? '0', context, showApproveAmount),

          child: CustomTileListingWidget(
            text1: item.date?.split(' ')[0] ?? '',
            text2: item.amount ?? '',
            subText2: 'Note: ${item.note ?? ''}',
            listRights: listRights,
            onView:
                () => navigateToDetail(
                  item.id ?? '0',
                  context,
                  showApproveAmount,
                ),
            onEdit:
                () => NavigationService.navigateToScreen(
                  context: context,
                  screen: SubmitSalaryAdvanceScreen(advanceId: item.id ?? '0'),
                ),
            onDelete:
                () => ref
                    .read(salaryAdvanceControllerProvider.notifier)
                    .deleteSalaryAdvance(
                      context: context,
                      salaryAdvanceId: item.id,
                    ),
          ),
        );
      },
    );
  }

  void navigateToDetail(
    String advanceId,
    BuildContext context,
    bool showApproveAmount,
  ) {
    NavigationService.navigateToScreen(
      context: context,
      screen: SalaryAdvanceDetailScreen(
        advanceId: advanceId,
        showApproveAmount: showApproveAmount,
      ),
    );
  }
}
