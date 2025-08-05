class LeaveManagementApis {
  static const String submitLeaveFirstApi =
      '/api/Leave/LEAV_GETLEAVESETTINGS_OTHER';
  static const String submitLeave =
      '/api/Leave/SaveLeaveMobAppESS/saveLeaveApi';

  static const String deleteLeave = '/api/Leave/DeleteLeaveMobApp/deleteLeave';
  static const String cancelLeave = '/api/Leave/CancelRequest/cancelRequestApi';
  static const String getEditLeaveDetails =
      '/api/Leave/Get_Sel_Leave/getLeaveDetails';

  static const String getSelfLeaveDetails =
      '/api/Leave/Get_Sel_Leave/getLeaveDetails';
  static const String getApprovalLeaveDetails =
      '/api/Leave/Get_Datatoapprove/getLMLeaveDetails';
  static const String getSubmittedLeaves =
      '/api/Leave/Get_SS_SubLeaves/getSubmittedLeaves';
  static const String getApprovedLeaves =
      '/api/Leave/Get_SS_ApprLeaves/getApprovedLeaves';
  static const String getRejectedLeaves =
      '/api/Leave/Get_SS_RejLeaves/getRejectedLeaves';
  static const String getCancelledLeaves =
      '/api/Leave/Get_SS_CanLeaves/getCancelledLeaves';

  static const String getLeaveTypes =
      '/api/Leave/GetEmpLeaveTypes/getEmployeLeaveTypes';
  static const String getTotalLeaveDays = '/api/Leave/CalculateLeave';
  static const String getResumptionDetails =
      '/api/Leave/Get_Sel_Resumption/getResumptionDetails';
  static const String getEmployeeLeaveTypes =
      '/api/Leave/GetEmpLeaveTypes/getEmployeLeaveTypes';
  static const String getResumptionLeaves = '/api/Leave/Get_Resumption_Leaves';
}
