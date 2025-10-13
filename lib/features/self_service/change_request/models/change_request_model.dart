class ChangeRequestModel {
  final int? chrqcd;
  final String? chrqdt;
  final String? oldBcAcNo, oldBcAcNm, oldBaCode, oldBaName;
  final String? cOprtn;
  final String? suconn;
  final int? emcode;
  final String? chrqtp;
  final String? chrqtpText;
  final int? bacode;
  final String? bcacno;
  final String? bcacnm;
  final String? chrqst;
  final String? chapby;
  final String? chapdt;
  final String? comment;
  final String? sucode;
  final String? bankNameDetail;
  final List<ChangeRequestDetailModel> detail;
  ChangeRequestModel({
    required this.chrqcd,
    required this.sucode,
    this.cOprtn,
    this.oldBaCode,
    this.oldBcAcNm,
    this.oldBcAcNo,
    this.oldBaName,
    required this.suconn,
    required this.chrqdt,
    required this.emcode,
    required this.chrqtp,
    this.chrqtpText,
    required this.bacode,
    this.bcacno,
    this.bcacnm,
    this.bankNameDetail,
    required this.chrqst,
    this.chapby,
    this.chapdt,
    this.comment,
    required this.detail,
  });
  factory ChangeRequestModel.fromJson(Map<String?, dynamic> json) {
    final data = json['data'] as List?;
    final header =
        (data != null && data.isNotEmpty && (data[0] as List).isNotEmpty)
            ? data[0][0] as Map<String?, dynamic>
            : null;
    final details =
        (data != null && data.length > 1)
            ? (data[1] as List)
                .map((e) => ChangeRequestDetailModel.fromJson(e))
                .toList()
            : <ChangeRequestDetailModel>[];
    return ChangeRequestModel(
      chrqcd: header?['chrqcd'],
      sucode: header?['sucode'],
      chrqdt: header?['chrqdt'],
      emcode: header?['emcode'],
      chrqtp: header?['chrqtp'],
      chrqtpText: header?['chrqtp_text'],
      bacode: header?['bacode'],
      bcacno: header?['bcacno'],
      bcacnm: header?['bcacnm'],
      bankNameDetail: header?['baname'],
      chrqst: header?['chrqst'],
      chapby: header?['chapby'],
      chapdt: header?['chapdt'],
      comment: header?['chapnt'],
      detail: details,
      suconn: '',
      cOprtn: "",
    );
  }
  Map<String?, dynamic> toJson() => {
    "baName": bankNameDetail,
    "suconn": suconn,
    "sucode": sucode,
    "iChrqcd": chrqcd,
    "chRqTp": chrqtp,
    "emCode": emcode,
    "chRqDt": chrqdt,
    "baCode": bacode,
    "bcAcNo": bcacno ?? "",
    "bcAcNm": bcacnm ?? "",
    "chRqSt": chrqst,
    "oldBcAcNm": oldBcAcNm,
    "oldBaName": oldBaName,
    "oldBcAcNo": oldBcAcNo,
    "oldBaCode": oldBaCode,
    "cOprtn": "E",
    "detail": detail.map((e) => e.toJson()).toList(),
  };
}

class ChangeRequestDetailModel {
  final int? chRqCd;
  final String? chtype;
  final String? chvalu;
  final String? chtext;
  final String? oldChvalu;
  ChangeRequestDetailModel({
    this.chRqCd,
    this.chtext,
    required this.chtype,
    required this.oldChvalu,
    required this.chvalu,
  });
  factory ChangeRequestDetailModel.fromJson(Map<String?, dynamic> json) {
    return ChangeRequestDetailModel(
      chRqCd: json['chRqCd'] ?? 0,
      chtype: json['chtype'],
      chvalu: json['chvalu'],
      chtext: json['chtext'],
      oldChvalu: json['oldChvalu'] ?? '',
    );
  }
  Map<String?, dynamic> toJson() => {
    "chRqCd": chRqCd ?? 0,
    "chtype": chtype,
    "chvalu": chvalu,
    "oldChvalu": oldChvalu,
  };
}
