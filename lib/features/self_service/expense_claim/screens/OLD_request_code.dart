//
// class SubmitExpenseClaimScreen extends ConsumerStatefulWidget {
//   final String? claimId;
//   const SubmitExpenseClaimScreen({super.key, this.claimId});
//
//   @override
//   ConsumerState<SubmitExpenseClaimScreen> createState() =>
//       _SubmitExpenseClaimScreenState();
// }
//
// class _SubmitExpenseClaimScreenState
//     extends ConsumerState<SubmitExpenseClaimScreen> {
//   final TextEditingController monthYearController = TextEditingController();
//   final TextEditingController noteController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
//   final selectedAllowance = StateProvider<String>((ref) => '');
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   bool isEditMode = false;
//   bool hasPreFilled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     isEditMode = widget.claimId != null;
//   }
//
//   void prefillFieldsIfNeeded(ExpenseClaimModel? model) {
//     if (hasPreFilled || model == null) return;
//     monthYearController.text = model.monthyear ?? '';
//     noteController.text = model.note ?? '';
//     amountController.text = model.amount ?? '';
//     Future.microtask(() {
//       ref.read(selectedAllowance.notifier).state =
//           model.allowanceCode.toString();
//     });
//     hasPreFilled = true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isLoading = ref.watch(expenseClaimControllerProvider);
//
//     final AsyncValue<ExpenseClaimModel?>? details =
//         isEditMode
//             ? ref.watch(
//               expenseClaimDetailsProvider(
//                 int.tryParse(widget.claimId ?? '0') ?? 0,
//               ),
//             )
//             : null;
//
//     final data = details?.maybeWhen(data: (d) => d, orElse: () => null);
//     if (data != null) prefillFieldsIfNeeded(data);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           isEditMode
//               ? '${'Edit'.tr()} ${'expense_claim_request'.tr()}'
//               : '${submitText.tr()} ${'expense_claim_request'.tr()}',
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child:
//             details?.when(
//               loading: () => const Loader(),
//               error: (err, _) => Center(child: Text('Error: $err')),
//               data: (_) => _buildForm(context, isLoading, data?.reqdate),
//             ) ??
//             _buildForm(context, isLoading, null), // when not in edit mode
//       ),
//     );
//   }
//
//   Widget _buildForm(
//     BuildContext context,
//     bool isLoading,
//     String? submittedDate,
//   ) {
//     return Padding(
//       padding: AppPadding.screenPadding,
//       child: Form(
//         key: _formKey,
//         child: ListView(
//           children: [
//             submittedDate == null
//                 ? labelText('submitting_date'.tr())
//                 : labelText('submitted_date'.tr()),
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Text(
//                 submittedDate ?? formatDate(DateTime.now()),
//                 style: TextStyle(fontSize: 14.sp),
//               ),
//             ),
//             12.heightBox,
//             labelText('requested_month_and_year'.tr(), isRequired: true),
//             MonthYearPickerField(
//               controller: monthYearController,
//               label: "select_duration".tr(),
//             ),
//             12.heightBox,
//             labelText('amount'.tr(), isRequired: true),
//             inputField(
//               hint: "enter".tr(),
//               keyboardType: TextInputType.number,
//               controller: amountController,
//             ),
//             12.heightBox,
//             labelText('expense_claim'.tr(), isRequired: true),
//
//             ref
//                 .watch(allowanceTypesProvider)
//                 .when(
//                   data: (allowanceTypes) {
//                     final selected = ref.watch(selectedAllowance);
//
//                     if (selected.isEmpty && allowanceTypes.isNotEmpty) {
//                       Future.microtask(() {
//                         ref.read(selectedAllowance.notifier).state =
//                             allowanceTypes.first.allowanceValue ?? '';
//                       });
//                     }
//
//                     return CustomDropdown(
//                       onChanged: (allowanceValue) {
//                         ref.read(selectedAllowance.notifier).state =
//                             allowanceValue ?? "0";
//                       },
//                       items:
//                           allowanceTypes
//                               .map(
//                                 (e) => DropdownMenuItem<String>(
//                                   value: e.allowanceValue,
//                                   child: Text(e.allowanceType ?? ''),
//                                 ),
//                               )
//                               .toList(),
//                       value: selected.isEmpty ? null : selected,
//                       hintText: "select_type".tr(),
//                     );
//                   },
//                   error: (error, _) => Center(child: Text('$error')),
//                   loading: () => const Loader(),
//                 ),
//
//             12.heightBox,
//             FileUploadButton(),
//             labelText('note'.tr()),
//             inputField(
//               hint: 'enter_your_note'.tr(),
//               minLines: 3,
//               controller: noteController,
//               isRequired: false,
//             ),
//             12.heightBox,
//             isLoading
//                 ? Loader()
//                 : SizedBox(
//                   width: double.infinity,
//                   child: CustomElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate() &&
//                           monthYearController.text.isNotEmpty &&
//                           ref.watch(selectedAllowance).isNotEmpty) {
//                         final expenseClaim = ExpenseClaimModel(
//                           monthyear: monthYearController.text,
//                           reqdate:
//                               submittedDate ??
//                               DateTime.now().toString().split(' ')[0],
//                           note: noteController.text,
//                           amount: amountController.text,
//                           allowanceCode: int.parse(
//                             ref.watch(selectedAllowance),
//                           ),
//                           crcode: '0',
//                           url: '',
//                           expnam: '',
//                           iEcid: int.parse(widget.claimId ?? '0'),
//                         );
//
//                         ref
//                             .read(expenseClaimControllerProvider.notifier)
//                             .submitExpenseClaim(
//                               expenseClaim: expenseClaim,
//                               context: context,
//                               isEditMode: isEditMode,
//                             );
//                       } else {
//                         showCustomAlertBox(
//                           context,
//                           title: "pleaseFillRequiredFields".tr(),
//                           type: AlertType.error,
//                         );
//                       }
//                     },
//                     child: Text(
//                       isEditMode ? updateText.tr() : submitText.tr(),
//                       style: TextStyle(fontSize: 14.sp),
//                     ),
//                   ),
//                 ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     monthYearController.dispose();
//     noteController.dispose();
//     amountController.dispose();
//     hasPreFilled = false;
//   }
// }
