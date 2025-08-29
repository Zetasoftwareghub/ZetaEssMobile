class ChangeRequestApis {
  static const String submitChangeRequest =
      '/api/ChangeRequest/SaveChangeRequest';

  static const String getChangeRequestList =
      '/api/ChangeRequest/get_ss_changerequestlist';

  static const String getChangeRequestsDropDown =
      '/api/ChangeRequest/BindDrpData';

  static const String deleteChangeRequests =
      '/api/ChangeRequest/deleteChangeRequest';

  static const String getChangeRequestDetails =
      '/api/ChangeRequest/GetSavedChangeRequestData';

  static const String getApprovalChangeRequestDetails =
      '/api/Leave/Get_ResReq_AppData_MobileApp/getLMChangeRequestRequestDetails';

  static const String bindBanksApi = '/api/ChangeRequest/BindBanks';

  static const String getCountryDetails =
      '/api/ChangeRequest/GetCountryDetails';

  static const String getPassportDetails = '/api/ChangeRequest/passportdetails';

  static const String getAddressContactDetails =
      '/api/ChangeRequest/GetCurrentAddress';

  static const String getMaritalStatus = '/api/ChangeRequest/Getmaritalstatus';

  static const String getCurrentBankDetails =
      '/api/ChangeRequest/getCurrentBankDetails';
}
