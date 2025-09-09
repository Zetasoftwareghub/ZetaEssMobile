import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/self_service/salary_advance/screens/salaryAdvanceDetail_screen.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../controller/approve_salary_advance_controller.dart';
import '../models/approve_salary_advance_listing_model.dart';

class ApproveSalaryAdvanceListingScreen extends ConsumerWidget {
  final String title;

  const ApproveSalaryAdvanceListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salaryList = ref.watch(approveSalaryAdvanceListProvider);
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
              child: salaryList.when(
                data: (data) {
                  return TabBarView(
                    children: [
                      SalaryAdvanceListView(
                        salaryList: data.submitted,
                        isLineManger: true,
                        showApproveAmount: false,
                      ),
                      SalaryAdvanceListView(salaryList: data.approved),
                      SalaryAdvanceListView(
                        salaryList: data.rejected,
                        showApproveAmount: false,
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

class SalaryAdvanceListView extends StatelessWidget {
  final List<ApproveSalaryAdvanceListingModel> salaryList;
  final bool? isLineManger;
  final bool showApproveAmount;
  const SalaryAdvanceListView({
    super.key,
    required this.salaryList,
    this.isLineManger,
    this.showApproveAmount = true,
  });

  @override
  Widget build(BuildContext context) {
    if (salaryList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }
    return ListView.builder(
      padding: EdgeInsets.all(12.r),
      itemCount: salaryList.length,
      itemBuilder: (context, index) {
        final salary = salaryList[index];
        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: SalaryAdvanceDetailScreen(
                  isLineManager: isLineManger,
                  advanceId: salary.id,
                  showApproveAmount: showApproveAmount,
                ),
              ),
          child: CustomTileListingWidget(
            text1: '  Month  ',
            subText1: salary.dateFrom,
            text2: 'Name: ${salary.name ?? 'no name'}',
            subText2: "Amount : ${salary.amount}",
          ),
        );
      },
    );
  }
}
