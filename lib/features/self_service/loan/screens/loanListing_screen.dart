import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/common/error_text.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';
import 'package:zeta_ess/features/self_service/loan/controller/loan_controller.dart';
import 'package:zeta_ess/features/self_service/loan/models/loan_list_model.dart';
import 'package:zeta_ess/features/self_service/loan/screens/loanDetail_screen.dart';
import 'package:zeta_ess/features/self_service/loan/screens/submitLoan_screen.dart';
import 'package:zeta_ess/models/listRights_model.dart';

import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../providers/loan_providers.dart';

class LoanListingScreen extends ConsumerWidget {
  final String title;

  const LoanListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanListAsync = ref.watch(loanListProvider);

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
              child: loanListAsync.when(
                data: (loanListResponse) {
                  return TabBarView(
                    children: [
                      LoanListView(
                        loanList: loanListResponse.submitted.loanList,
                        rightsModel: loanListResponse.submitted.listRights,
                      ),
                      LoanListView(
                        loanList: loanListResponse.approved,
                        isApproveTab: true,
                      ),
                      LoanListView(loanList: loanListResponse.rejected),
                    ],
                  );
                },
                loading: () => Loader(),
                error: (err, _) => ErrorText(error: err.toString()),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            NavigationService.navigateToScreen(
              context: context,
              screen: SubmitLoanScreen(),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class LoanListView extends ConsumerWidget {
  final List<LoanListModel> loanList;
  final ListRightsModel? rightsModel;
  final bool isApproveTab;
  const LoanListView({
    super.key,
    required this.loanList,
    this.rightsModel,
    this.isApproveTab = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loanList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.r).copyWith(bottom: 80.h),
      itemCount: loanList.length,
      itemBuilder: (context, index) {
        final loan = loanList[index];
        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: LoanDetailScreen(
                  loanId: loan.loanId,
                  loanListModel: loan,
                  isSelf: true,
                  isApproveTab: isApproveTab,
                ),
              ),
          child: CustomTileListingWidget(
            listRights: rightsModel,
            text1: convertRawDateToString(loan.submittedDate),
            text2: ' ${loan.loanType}',
            subText2:
                "Status :${loan.loanStatus ?? ''}, Amount:  ${loan.loanAmount}",
            onView:
                () => NavigationService.navigateToScreen(
                  context: context,
                  screen: LoanDetailScreen(
                    isSelf: true,
                    isApproveTab: isApproveTab,
                    loanId: loan.loanId,
                    loanListModel: loan,
                  ),
                ),
            onEdit:
                () => NavigationService.navigateToScreen(
                  context: context,
                  screen: SubmitLoanScreen(loanId: loan.loanId),
                ),
            onDelete:
                () => ref
                    .read(loanControllerProvider.notifier)
                    .deleteLoan(
                      loanId: int.parse(loan.loanId),
                      context: context,
                    ),
          ),
        );
      },
    );
  }
}
