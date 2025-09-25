import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/self_service/loan/screens/loanDetail_screen.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../self_service/loan/models/loan_list_model.dart';
import '../controller/approve_loan_controller.dart';

class ApproveLoanListingScreen extends ConsumerWidget {
  final String title;

  const ApproveLoanListingScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanListAsync = ref.watch(approveLoanListProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(title.tr())),
        body: Column(
          children: [
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              tabs: approvalListTabs.map((tab) => Tab(text: tab.tr())).toList(),

              indicatorColor: Colors.blue,
            ),
            Expanded(
              child: loanListAsync.when(
                data: (loanListResponse) {
                  return TabBarView(
                    children: [
                      LoanListView(
                        loanList: loanListResponse.pending,
                        isLineManger: true,
                      ),
                      LoanListView(loanList: loanListResponse.approved),
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
      ),
    );
  }
}

class LoanListView extends ConsumerWidget {
  final List<LoanListModel> loanList;
  final bool? isLineManger;
  const LoanListView({super.key, required this.loanList, this.isLineManger});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loanList.isEmpty) {
      return Center(child: Text("No records found".tr()));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.r),
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
                  isLineManager: isLineManger ?? false,
                ),
              ),
          child: CustomTileListingWidget(
            text1: convertRawDateToString(loan.submittedDate),
            text2: 'Name: ${loan.requestEmpname}\nType: ${loan.loanType}',
            subText2: "Amount:  ${loan.loanAmount}",
          ),
        );
      },
    );
  }
}

//
// class ApproveLoanListingScreen extends StatelessWidget {
//   final String title;
//
//   const ApproveLoanListingScreen({super.key, required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(title: Text(title)),
//         body: Column(
//           children: [
//             TabBar(
//               tabAlignment: TabAlignment.center,
//               isScrollable: true,
//               tabs: listTabs.map((tab) => Tab(text: tab.tr())).toList(),
//
//               indicatorColor: Colors.blue,
//             ),
//             Expanded(
//               child: TabBarView(
//                 children: [LoanListView(), LoanListView(), LoanListView()],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class LoanListView extends StatelessWidget {
//   const LoanListView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: EdgeInsets.all(12.r),
//       itemCount: 8,
//       itemBuilder: (context, index) {
//         return InkWell(
//           onTap:
//               () => NavigationService.navigateToScreen(
//                 context: context,
//                 screen: LoanDetailScreen(isLineManager: true, loanId: ''),
//               ),
//           child: CustomTileListingWidget(
//             text1: "10-Oct",
//             subText1: "2025",
//             text2: "Education Loan",
//             subText2: "Amount:  5000",
//           ),
//         );
//       },
//     );
//   }
// }
