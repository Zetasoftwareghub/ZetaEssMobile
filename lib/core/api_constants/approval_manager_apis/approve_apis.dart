class ApproveApis {
  //APPROVE APIS
  static const String approveRejectResumption =
      '/api/Leave/ApproveResumption_MobileApp/approveResumption';

  static const String approveLeave =
      '/api/Leave/ApproveLeaveMobApp/approveLeave';
  static const String rejectLeave = '/api/Leave/RejectLeaveMobApp/rejectLeave';

  static const String approveRejectLieu =
      '/api/Leave/ApproveLieuday_MobileApp/approveLieuDay';

  static const String rejectSalaryAdvance =
      '/api/SalAdvance/RejectRecord/salaryAdvanceReject';
  static const String approveSalaryAdvance =
      '/api/SalAdvance/ApproveRecord/salaryAdvanceAction';

  static const String approveExpenseClaim =
      '/api/ExpClaim/ApproveRecord/expenseClaimApprove';
  static const String rejectExpenseClaim =
      '/api/ExpClaim/RejectRecord/expenseClaimReject';

  static const String approveRejectSalaryCertificate =
      '/api/SalCertificate/ApprRejectRecord/salaryCertificateAction';

  static const String approveRejectRegularisation =
      '/api/Attendance/ApproveRegularization_MobileApp/approveRegularization';

  static const String approveRejectOtherRequest =
      '/api/OtherRequest/ApproveRejectRequest/approveOtherRq';

  //GET LIST APIS
  static const String getApproveRegulariseDetails =
      '/api/Leave/Get_AttReg_AppData_MobileApp/getLMAttendanceRegularizationDetails';
  static const String getApproveLeaveList =
      '/api/Leave/Get_LM_AllList/getLMLeaves';
  static const String getApproveLieuDayList =
      '/api/Leave/Get_LieudayRequest_LMAllList/getLMLieudayRequest';
  static const String getApproveSalaryAdvanceList =
      '/api/Leave/Get_LM_AllListSaladvance/getLMSalaryAdvance';
  static const String getApproveExpenseClaimList =
      '/api/ExpClaim/Get_LM_AllList/getLMExpenseClaimList';
  static const String getApproveRegularisationList =
      '/api/Leave/Get_AttendanceRegularization_AllList/getLMAttendanceRegularization';
  static const String getApproveOtherRequestList =
      '/api/Leave/Get_OTHER_LMList/lMGetOtherRqLst';

  static const String getApproveSalaryCertificateList =
      '/api/Leave/Get_LM_AllListSalcert/getLMSalaryCertificates';
  static const String getApproveResumptionList =
      '/api/Leave/Get_ResumptionRequest_LMAllList/getLMResumptionRequest';

  static String get approveRejectLoan =>
      '/api/LoanRequest/LoanRequestApproveReject';

  static String get getApproveLoanListApi =>
      '/api/LoanRequest/Get_LM_LoanRequestList';
}
