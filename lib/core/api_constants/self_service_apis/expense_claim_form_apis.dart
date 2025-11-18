class ExpenseClaimFormApis {
  static const String base = "/api/ExpenseClaimForm";

  static const String getList = "$base/Get_SS_ExpClaimFormList";
  static const String bindExpenseCategoryGroup =
      "$base/BindExpenseCategoryGroup";
  static const String bindExpenseCategory = "$base/BindExpenseCategory";
  static const String bindAdvanceNumber = "$base/BindAdvanceNumber";
  static const String saveExpClaimForm = "$base/SaveExpClaimForm";
  static const String deleteExpClaimForm = "$base/DeleteExpClaimForm";
  static const String approveReject = "$base/ExpClaimFormApproveReject";
  static const String details = "$base/ExpClaimFormDetails";
  static const String bindBusinessDescription = "$base/BindBusinessDescription";
  static const String bindCurrency = "$base/BindCurrency";
}
