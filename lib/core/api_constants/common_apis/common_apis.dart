class CommonApis {
  static const String getPendingRequest = '/api/Ess/GetEssPendingReq';
  static const String getPendingApprovals = '/api/Ess/GetEssNotification';

  static const String getAnnouncements = '/api/Leave/GetAnnouncements';
  static const String changePassword = '/api/login/ChangePassword';

  static const String getPaySlips =
      '/api/ZetahrmsAPI/GetPayslipInfo/getPaySlips';
  static const String paySlipDownloadUrl =
      '/api/ZetahrmsAPI/GeneratePayslip/downloadPaySlip';

  static const String getDownloads = '/api/ZetahrmsAPI/GetDownloads';

  static const String getHolidayCalendar =
      '/api/Leave/GetHolidayCalenderDivisionwisenw/holidayCalendars';
  static const String getHolidayCalendarRegion =
      '/api/Leave/GetHolidayCalenderDivisionnw/holidayCalendarRegion';

  static const String getLeaveBalance = '/api/Leave/GetLeaveBalance';
  static const String getPunchDetails =
      '/api/Dash/Get_AttendanceLocn_MbappNW/getPunchDetails';
  static const String savePunch = '/api/Dash/INS_ATTDNCE_WTH_LOCN/savePunch';
}
