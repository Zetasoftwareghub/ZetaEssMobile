import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/features/approval_management/approveExpense_claim/controller/approve_expense_claim_controller.dart';
import 'package:zeta_ess/features/approval_management/approveExpense_claim/models/approve_expense_claim_listing_model.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/services/NavigationService.dart';
import '../../../../core/utils.dart';
import '../../../self_service/expense_claim/screens/expenseClaimDetails_screen.dart';

class ApproveExpenseClaimListingScreen extends ConsumerWidget {
  final String title;

  const ApproveExpenseClaimListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseClaimList = ref.watch(approveExpenseClaimListProvider);
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
              child: expenseClaimList.when(
                data: (data) {
                  return TabBarView(
                    children: [
                      ExpenseClaimListView(
                        expenseClaimList: data.submitted,
                        isLineManager: true,
                      ),
                      ExpenseClaimListView(expenseClaimList: data.approved),
                      ExpenseClaimListView(expenseClaimList: data.rejected),
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

class ExpenseClaimListView extends StatelessWidget {
  final bool? isLineManager;
  final List<ApproveExpenseClaimListingModel> expenseClaimList;
  const ExpenseClaimListView({
    super.key,
    required this.expenseClaimList,
    this.isLineManager,
  });

  @override
  Widget build(BuildContext context) {
    if (expenseClaimList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }
    return ListView.builder(
      padding: EdgeInsets.all(12.r),
      itemCount: expenseClaimList.length,
      itemBuilder: (context, index) {
        final item = expenseClaimList[index];
        return InkWell(
          onTap: () {
            NavigationService.navigateToScreen(
              context: context,
              screen: ExpenseClaimDetailsScreen(
                isLineManager: isLineManager,
                expenseClaimId: int.parse(item.id ?? '0'),
              ),
            );
          },
          child: CustomTileListingWidget(
            text1: '  ${'Month'.tr()}  ',
            subText1: item.monthYear ?? '',
            text2: '${'Name'.tr()}: ${item.emname ?? 'no name'}',
            subText2: "${'Amount'.tr()}: ${item.amount}",
          ),
        );
      },
    );
  }
}
