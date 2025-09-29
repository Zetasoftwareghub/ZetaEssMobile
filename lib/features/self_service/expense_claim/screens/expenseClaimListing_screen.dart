import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/self_service/expense_claim/controller/expenseClaim_controller.dart';
import 'package:zeta_ess/features/self_service/expense_claim/screens/submitExpenseClaim_screen.dart';
import 'package:zeta_ess/models/listRights_model.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../models/expense_claim_model.dart';
import '../providers/expense_claim_providers.dart';
import 'expenseClaimDetails_screen.dart';

class ExpenseClaimListingScreen extends ConsumerStatefulWidget {
  final String title;

  const ExpenseClaimListingScreen({super.key, required this.title});

  @override
  ConsumerState<ExpenseClaimListingScreen> createState() =>
      _ExpenseClaimListingScreenState();
}

class _ExpenseClaimListingScreenState
    extends ConsumerState<ExpenseClaimListingScreen> {
  @override
  Widget build(BuildContext context) {
    final claimState = ref.watch(expenseClaimListProvider);

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
              child: claimState.when(
                data: (data) {
                  return TabBarView(
                    children: [
                      ExpenseClaimListView(
                        items: data.submitted.expenseClaimList,
                        listRights: data.submitted.listRights,
                      ),
                      ExpenseClaimListView(
                        items: data.approved,
                        isApprovedTab: true,
                      ),
                      ExpenseClaimListView(items: data.rejected),
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
              screen: SubmitExpenseClaimScreen(),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class ExpenseClaimListView extends StatelessWidget {
  final List<ExpenseClaimModel> items;
  final ListRightsModel? listRights;
  final bool isApprovedTab;
  const ExpenseClaimListView({
    super.key,
    required this.items,
    this.listRights,
    this.isApprovedTab = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.r).copyWith(bottom: 80.h),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final claim = items[index];
        return InkWell(
          onTap: () => navigateToDetail(claim, context),
          child: Consumer(
            builder: (context, ref, child) {
              return CustomTileListingWidget(
                text1: claim.monthyear,
                subText1: "requested_date".tr(),
                text2: claim.expenseClaimName,
                subText2:
                    "Status: ${claim.employeeName}, Amount: ${claim.approveAmount != null && claim.approveAmount != '0' ? claim.approveAmount : claim.amount}",
                listRights: listRights,
                onView: () => navigateToDetail(claim, context),

                onEdit:
                    () => NavigationService.navigateToScreen(
                      context: context,
                      screen: SubmitExpenseClaimScreen(
                        claimId: claim.expenseClaimId.toString(),
                      ),
                    ),
                onDelete:
                    () => ref
                        .read(expenseClaimControllerProvider.notifier)
                        .deleteExpenseClaim(
                          context: context,
                          claimId: claim.expenseClaimId,
                        ),
              );
            },
          ),
        );
      },
    );
  }

  void navigateToDetail(ExpenseClaimModel claim, BuildContext context) {
    NavigationService.navigateToScreen(
      context: context,
      screen: ExpenseClaimDetailsScreen(
        expenseClaimId: claim.expenseClaimId,
        isApprovedTab: isApprovedTab,
      ),
    );
  }
}
