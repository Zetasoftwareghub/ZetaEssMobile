// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../../core/providers/userContext_provider.dart';
// import '../../expense_claim/providers/expense_claim_providers.dart';
// import '../models/save_claim_model.dart';
// import '../providers/form_providers.dart';
//
// final submitExpenseClaimProvider =
//     StateNotifierProvider<SubmitExpenseClaimNotifier, AsyncValue<bool>>(
//       (ref) => SubmitExpenseClaimNotifier(ref),
//     );
//
// class SubmitExpenseClaimNotifier extends StateNotifier<AsyncValue<bool>> {
//   final Ref ref;
//
//   SubmitExpenseClaimNotifier(this.ref) : super(const AsyncValue.data(false));
//
//   Future<void> submit() async {
//     try {
//       state = const AsyncLoading();
//
//       final user = ref.read(userContextProvider);
//       final advance = ref.read(advanceProvider);
//       final includeGift = ref.read(includeBusinessGiftProvider);
//
//       final expenseList = ref.read(expenseDetailsProvider);
//       final giftList = ref.read(businessGiftsProvider);
//       final advanceList = ref.read(advancePaymentsProvider);
//       final attachments = ref.read(attachmentsProvider);
//
//       final model = SaveExpenseClaimModel(
//         suconn: user.companyConnection,
//         exmtid: 0,
//         hfEmcode: int.parse(user.empCode),
//         reqDate: DateTime.now().toIso8601String(),
//         reqNo: 0,
//         advPay: advance ? "Y" : "N",
//         busGift: includeGift ? "Y" : "N",
//         paymentMode: 0,
//         mth: "",
//         paymentMonth: "",
//         comments: ref.read(commentProvider),
//         emcode: int.parse(user.empCode),
//         amtpad: 0,
//         exstype: "",
//         exsdisplay: "",
//         repMnth: ref.read(monthPickerProvider),
//         repayCashDate: "",
//         expDetls: expenseList,
//         bsnsGft: giftList,
//         cashAdvnc: advanceList,
//         attachments: attachments,
//         baseDirectory: "",
//         extotl: ref.read(expenseDetailsProvider.notifier).totalExpenseAmount,
//         bgtotl: ref.read(businessGiftsProvider.notifier).totalGiftAmount,
//         sbtotl: 0,
//         adtotl: ref.read(advancePaymentsProvider.notifier).totalAdvanceAmount,
//         ampaid: 0,
//       );
//
//       final repo = ref.read(expenseClaimRepositoryProvider);
//       final response = await repo.submitExpenseClaim(model);
//
//       if (!response.isSuccess) {
//         throw Exception(response.message);
//       }
//
//       state = const AsyncData(true);
//     } catch (e) {
//       state = AsyncError(e, StackTrace.current);
//     }
//   }
// }
