// // Expense List Item Widget
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
//
// import '../../models/advance_model.dart';
// import '../../models/bussiness_gift_model.dart';
// import '../../models/expense_detail_model.dart';
//
// class ExpenseListItem extends StatelessWidget {
//   final ExpenseDetailModel expense;
//   final int index;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   const ExpenseListItem({
//     required this.expense,
//     required this.index,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.blue[100],
//           child: Text(
//             '${index + 1}',
//             style: TextStyle(
//               color: Colors.blue[800],
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         title: Text(
//           expense.description.length > 30
//               ? '${expense.description.substring(0, 30)}...'
//               : expense.description,
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('${"Date:".tr()} ${expense.date}'),
//             Text(
//               '${"Amount:".tr()} ${expense.currency} ${expense.expenseAmount}',
//             ),
//             Text('${"Category:".tr()} ${expense.expenseAnalysis}'),
//           ],
//         ),
//         trailing: PopupMenu(onEdit: onEdit, onDelete: onDelete),
//         onTap: onEdit,
//       ),
//     );
//   }
// }
//
// // Advance Payment List Item Widget
// class AdvancePaymentListItem extends StatelessWidget {
//   final AdvancePaymentModel? payment;
//   final int index;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   const AdvancePaymentListItem({
//     required this.payment,
//     required this.index,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.green[100],
//           child: Text(
//             '${index + 1}',
//             style: TextStyle(
//               color: Colors.green[800],
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         title: Text(
//           'Payment #${payment?.paymentNumber}',
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('${"Currency:".tr()} ${payment?.currency}'),
//             Text('${"Amount:".tr()} ${payment?.currency} ${payment?.amount}'),
//             Text(
//               '${"Employee Currency:".tr()} AED ${payment?.amountInEmployeeCurrency}',
//             ),
//           ],
//         ),
//         trailing: PopupMenu(onEdit: onEdit, onDelete: onDelete),
//         onTap: onEdit,
//       ),
//     );
//   }
// }
//
// // Business Gift List Item Widget
// class BusinessGiftListItem extends StatelessWidget {
//   final BusinessGiftModel gift;
//   final int index;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   const BusinessGiftListItem({
//     required this.gift,
//     required this.index,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.purple[100],
//           child: Text(
//             '${index + 1}',
//             style: TextStyle(
//               color: Colors.purple[800],
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         title: Text(
//           gift.description.length > 30
//               ? '${gift.description.substring(0, 30)}...'
//               : gift.description,
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('${"Date:".tr()} ${gift.date}'),
//             Text('${"Company:".tr()} ${gift.guestCompanyName}'),
//             Text('${"Guests:".tr()} ${gift.numberOfGuests}'),
//             Text('${"Amount:".tr()} ${gift.currency} ${gift.expenseAmount}'),
//           ],
//         ),
//         trailing: PopupMenu(onEdit: onEdit, onDelete: onDelete),
//         onTap: onEdit,
//       ),
//     );
//   }
// }
//
// // Reusable Popup Menu Widget
// class PopupMenu extends StatelessWidget {
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   const PopupMenu({required this.onEdit, required this.onDelete});
//
//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton(
//       itemBuilder:
//           (context) => [
//             PopupMenuItem(
//               value: 'edit',
//               child: Row(
//                 children: [
//                   const Icon(Icons.edit, size: 20),
//                   const SizedBox(width: 8),
//                   Text('Edit'.tr()),
//                 ],
//               ),
//             ),
//             PopupMenuItem(
//               value: 'delete',
//               child: Row(
//                 children: [
//                   const Icon(Icons.delete, size: 20, color: Colors.red),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Delete'.tr(),
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//       onSelected: (value) {
//         if (value == 'edit') {
//           onEdit();
//         } else if (value == 'delete') {
//           onDelete();
//         }
//       },
//     );
//   }
// }
