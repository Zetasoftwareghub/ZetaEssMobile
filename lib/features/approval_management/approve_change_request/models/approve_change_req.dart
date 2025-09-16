class ApproveChangeRequestModel {
  final String? suconn;
  final int chRqCd;
  final String? chApBy;
  final String bcSlNo;
  final String sucode;
  final String? chapnt;
  final String emCode;
  final String? chtype;
  final String? aprFlag;

  ApproveChangeRequestModel({
    required this.suconn,
    required this.sucode,
    required this.chRqCd,
    required this.chApBy,
    required this.bcSlNo,
    required this.chapnt,
    required this.emCode,
    required this.chtype,
    required this.aprFlag,
  });

  factory ApproveChangeRequestModel.fromJson(Map<String?, dynamic> json) {
    return ApproveChangeRequestModel(
      suconn: json['suconn'] ?? '',
      sucode: json['sucode'] ?? '',
      chRqCd: json['chRqCd'] ?? 0,
      chApBy: json['chApBy'] ?? '',
      bcSlNo: json['bcSlNo'] ?? 0,
      chapnt: json['chapnt'] ?? '',
      emCode: json['emCode'] ?? 0,
      chtype: json['chtype'] ?? '',
      aprFlag: json['aprFlag'] ?? '',
    );
  }

  Map<String?, dynamic> toJson() {
    return {
      "sucode": sucode,
      'suconn': suconn,
      'chRqCd': chRqCd,
      'chApBy': chApBy,
      'bcSlNo': bcSlNo,
      'chapnt': chapnt,
      'emCode': emCode,
      'chtype': chtype,
      'aprFlag': aprFlag,
    };
  }
}
