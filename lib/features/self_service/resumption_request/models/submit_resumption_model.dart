class SubmitResumptionModel {
  final int reslno;
  final String suconn;
  final String emcode;
  final String micode;
  final String selectedValue;
  final String selectedText;
  final String resDate;
  final String note;
  final String mediafile;
  final String mediaExtension;
  final String selectedMeetingValue;
  final String laslno;
  final String lvtype;
  final String baseDirectory;

  SubmitResumptionModel({
    required this.reslno,
    required this.suconn,
    required this.emcode,
    required this.micode,
    required this.selectedValue,
    required this.selectedText,
    required this.resDate,
    required this.note,
    required this.mediafile,
    required this.mediaExtension,
    required this.selectedMeetingValue,
    required this.laslno,
    required this.lvtype,
    required this.baseDirectory,
  });

  factory SubmitResumptionModel.fromJson(Map<String, dynamic> json) {
    return SubmitResumptionModel(
      reslno: json['reslno'] ?? 0,
      suconn: json['suconn'] ?? '',
      emcode: json['emcode'] ?? '',
      micode: json['micode'] ?? '',
      selectedValue: json['selectedValue'] ?? '',
      selectedText: json['selectedText'] ?? '',
      resDate: json['resDate'] ?? '',
      note: json['note'] ?? '',
      mediafile: json['mediafile'] ?? '',
      mediaExtension: json['mediaExtension'] ?? '',
      selectedMeetingValue: json['selectedMeetingValue'] ?? '',
      laslno: json['laslno'] ?? '',
      lvtype: json['lvtype'] ?? '',
      baseDirectory: json['baseDirectory'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reslno': reslno,
      'suconn': suconn,
      'emcode': emcode,
      'micode': micode,
      'selectedValue': selectedValue,
      'selectedText': selectedText,
      'resDate': resDate,
      'note': note,
      'mediafile': mediafile,
      'mediaExtension': mediaExtension,
      'selectedMeetingValue': selectedMeetingValue,
      'laslno': laslno,
      'lvtype': lvtype,
      'baseDirectory': baseDirectory,
    };
  }
}
