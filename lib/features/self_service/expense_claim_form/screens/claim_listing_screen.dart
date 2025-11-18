// import 'package:flutter/material.dart';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:zeta_ess/core/common/loader.dart';
// import 'package:zeta_ess/core/services/NavigationService.dart';
// import 'package:zeta_ess/core/utils/date_utils.dart';
// import 'package:zeta_ess/features/self_service/expense_claim/controller/expenseClaim_controller.dart';
// import 'package:zeta_ess/features/self_service/expense_claim/screens/submitExpenseClaim_screen.dart';
// import 'package:zeta_ess/features/self_service/expense_claim_form/models/claim_list_response.dart';
// import 'package:zeta_ess/features/self_service/expense_claim_form/providers/api_providers.dart';
// import 'package:zeta_ess/features/self_service/expense_claim_form/screens/expense_claim_form_screen.dart';
// import 'package:zeta_ess/models/listRights_model.dart';
//
// import '../../../../core/common/error_text.dart';
// import '../../../../core/common/widgets/customTileListing_widget.dart';
// import '../../../../core/utils.dart';
//
// class ClaimListingScreen extends ConsumerStatefulWidget {
//   final String title;
//
//   const ClaimListingScreen({super.key, required this.title});
//
//   @override
//   ConsumerState<ClaimListingScreen> createState() => _ClaimListingScreenState();
// }
//
// class _ClaimListingScreenState extends ConsumerState<ClaimListingScreen> {
//   final _tabs = ["submitted", "approved", "rejected", "cancelled"];
//
//   @override
//   Widget build(BuildContext context) {
//     final claimState = ref.watch(claimListProvider);
//
//     return DefaultTabController(
//       length: 4,
//       child: Scaffold(
//         appBar: AppBar(title: Text(widget.title)),
//         body: Column(
//           children: [
//             TabBar(
//               tabAlignment: TabAlignment.center,
//               isScrollable: true,
//               indicatorColor: Colors.blue,
//               tabs: _tabs.map((tab) => Tab(text: tab.tr())).toList(),
//             ),
//             Expanded(
//               child: claimState.when(
//                 data: (data) {
//                   return TabBarView(
//                     children: [
//                       ClaimListView(
//                         items: data.subLst,
//                         listRights: data.rights,
//                       ),
//                       ClaimListView(items: data.appLst, isApprovedTab: true),
//                       ClaimListView(items: data.rejLst),
//                       ClaimListView(items: data.canLst),
//                     ],
//                   );
//                 },
//                 loading: () => const Loader(),
//                 error: (e, _) => ErrorText(error: e.toString()),
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             // NavigationService.navigateToScreen(
//             //   context: context,
//             //   screen: SubmitExpenseClaimForm(),
//             // );
//           },
//           child: const Icon(Icons.add),
//         ),
//       ),
//     );
//   }
// }
//
// class ClaimListView extends StatelessWidget {
//   final List<ClaimListData> items;
//   final ListRightsModel? listRights;
//   final bool isApprovedTab;
//   const ClaimListView({
//     super.key,
//     required this.items,
//     this.listRights,
//     this.isApprovedTab = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (items.isEmpty) {
//       return Center(child: Text("No records found".tr()));
//     }
//
//     return ListView.builder(
//       padding: EdgeInsets.all(12.r).copyWith(bottom: 80.h),
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         final claim = items[index];
//         return InkWell(
//           onTap: () => navigateToDetail(claim, context),
//           child: Consumer(
//             builder: (context, ref, child) {
//               return CustomTileListingWidget(
//                 text1: convertRawDateToString(claim.requestDate),
//                 subText1: "requested_date".tr(),
//                 text2: "${'amount'.tr()}: ${claim.paidAmount.toString()}",
//                 subText2: "${'Status'.tr()}: ${claim.approvalStatus}",
//                 listRights: listRights,
//                 onView: () => navigateToDetail(claim, context),
//
//                 // onEdit:
//                 //     () => NavigationService.navigateToScreen(
//                 //       context: context,
//                 //       screen: SubmitExpenseClaimScreen(
//                 //         claimId: claim.expenseClaimId.toString(),
//                 //       ),
//                 //     ),
//                 // onDelete:
//                 //     () => ref
//                 //         .read(expenseClaimControllerProvider.notifier)
//                 //         .deleteExpenseClaim(
//                 //           context: context,
//                 //           claimId: claim.expenseClaimId,
//                 //         ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   void navigateToDetail(ClaimListData claim, BuildContext context) {
//     // NavigationService.navigateToScreen(
//     //   context: context,
//     //   screen: ExpenseClaimDetailsScreen(
//     //     expenseClaimId: claim.expenseClaimId,
//     //     isApprovedTab: isApprovedTab,
//     //   ),
//     // );
//   }
// }
