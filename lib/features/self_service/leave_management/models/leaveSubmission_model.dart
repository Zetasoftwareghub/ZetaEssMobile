class LeaveSubmissionRequest {
  final String leaveCode;
  final String fromDate;
  final String toDate;
  final List dtldata;
  // final List<LeaveConfigurationData> dtldata;
  final String dtsub;
  final String note;
  final String contact;
  final String days;
  final String? file;
  final String fileExt;
  final String allowance;
  final String leaveId;
  final String baseDirectory;
  final bool fileDelete;

  LeaveSubmissionRequest({
    required this.leaveCode,
    required this.fromDate,
    required this.toDate,
    required this.dtldata,
    required this.dtsub,
    required this.note,
    required this.contact,
    required this.days,
    required this.file,
    required this.fileExt,
    required this.allowance,
    required this.leaveId,
    required this.baseDirectory,
    this.fileDelete = false,
  });

  Map<String, dynamic> toJson(
    String suconn,
    String sucode,
    String emcode,
    String username,
    String userId,
    String baseUrl,
  ) {
    return {
      "mediafile": file,
      "mediaExtension": fileExt,
      "suconn": suconn,
      "sucode": sucode,
      "sucode": sucode,
      "emcode": emcode,
      "username": username,
      "userid": userId,
      "lsslno": leaveId,
      "dtsub": dtsub,
      "leavecode": leaveCode,
      "dtfrm": fromDate,
      "dtto": toDate,
      "lsnote": note,
      "crtby": emcode,
      "contactno": contact,
      "noOfDays": days,
      "rqall": "1",
      "ltflag": "1",
      "url": "$baseUrl/",
      "cocode": "0",
      "dtldata": dtldata.map((e) => e.toJson()).toList(),
      "allowance_type": allowance,
      // 'baseDirectory': baseDirectory,
      'baseDirectory': baseDirectory,
      'fileDelete': fileDelete,
    };
  }
}
