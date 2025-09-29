class SubmitLieuDayRequest {
  final String rqldcode;
  final String sucode;
  final String? suconn;
  final String? emcode;
  final String micode;
  final String lieuDayDate;
  final String fromTime;
  final String toTime;
  final String lieuDayType;
  final String remarks;
  final String mediafile;
  final String mediaExtension;
  final String mediaName;
  final String baseDirectory;
  final bool? fileDelete;

  SubmitLieuDayRequest({
    required this.rqldcode,
    required this.sucode,
    required this.suconn,
    required this.emcode,
    required this.micode,
    required this.lieuDayDate,
    required this.fromTime,
    required this.toTime,
    required this.lieuDayType,
    required this.remarks,
    required this.mediafile,
    required this.mediaExtension,
    required this.mediaName,
    required this.baseDirectory,
    this.fileDelete,
  });

  factory SubmitLieuDayRequest.fromJson(Map<String, dynamic> json) {
    return SubmitLieuDayRequest(
      rqldcode: json['rqldcode'] ?? 0,
      sucode: json['sucode'] ?? 0,
      suconn: json['suconn'] ?? '',
      emcode: json['emcode'] ?? '',
      micode: json['micode'] ?? '',
      lieuDayDate: json['dpDate'] ?? '',
      fromTime: json['fromTime'] ?? '',
      toTime: json['toTime'] ?? '',
      lieuDayType: json['drpType'] ?? '',
      remarks: json['remarks'] ?? '',
      mediafile: json['mediafile'] ?? '',
      mediaExtension: json['mediaExtension'] ?? '',
      mediaName: json['mediaName'] ?? '',
      baseDirectory: json['baseDirectory'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rqldcode': rqldcode,
      "sucode": sucode,
      'suconn': suconn,
      'emcode': emcode,
      'micode': micode,
      'dpDate': lieuDayDate,
      'fromTime': fromTime,
      'toTime': toTime,
      'drpType': lieuDayType,
      'remarks': remarks,
      'mediafile': mediafile,
      'mediaExtension': mediaExtension,
      'mediaName': mediaName,
      'baseDirectory': baseDirectory,
      'fileDelete': fileDelete ?? false,
    };
  }
}
