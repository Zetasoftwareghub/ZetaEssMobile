class ChangeRequestModel {
  final int? chrqcd;
  final String? chrqdt;
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
  final List<ChangeRequestDetailModel> detail;

  ChangeRequestModel({
    required this.chrqcd,
    required this.sucode,
    this.cOprtn,
    required this.suconn,
    required this.chrqdt,
    required this.emcode,
    required this.chrqtp,
    this.chrqtpText,
    required this.bacode,
    this.bcacno,
    this.bcacnm,
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
    "cOprtn": "E",
    "detail": detail.map((e) => e.toJson()).toList(),
  };
}

class ChangeRequestDetailModel {
  final int? chRqCd;
  final String? chtype;
  final String? chvalu;

  ChangeRequestDetailModel({
    this.chRqCd,
    required this.chtype,
    required this.chvalu,
  });

  factory ChangeRequestDetailModel.fromJson(Map<String?, dynamic> json) {
    return ChangeRequestDetailModel(
      chRqCd: json['chRqCd'] ?? 0,
      chtype: json['chtype'],
      chvalu: json['chvalu'],
    );
  }

  Map<String?, dynamic> toJson() => {
    "chRqCd": chRqCd ?? 0,
    "chtype": chtype,
    "chvalu": chvalu,
  };
}

/*class SaveChangeRequestModel {
  final String? suconn;
  final int? iChrqcd;
  final String? chRqTp;
  final int? emCode;
  final String? chRqDt;
  final int? baCode;
  final String? bcAcNo;
  final String? bcAcNm;
  final String? chRqSt;
  final String? cOprtn;
  final List<SaveChangeRequestDetail> detail;

  SaveChangeRequestModel({
    required this.suconn,
    required this.iChrqcd,
    required this.chRqTp,
    required this.emCode,
    required this.chRqDt,
    required this.baCode,
    required this.bcAcNo,
    required this.bcAcNm,
    required this.chRqSt,
    required this.cOprtn,
    required this.detail,
  });

  Map<String?, dynamic> toJson() {
    return {
            "sucode": sucode,
'suconn': suconn,
      'iChrqcd': iChrqcd,
      'chRqTp': chRqTp,
      'emCode': emCode,
      'chRqDt': chRqDt,
      'baCode': baCode,
      'bcAcNo': bcAcNo,
      'bcAcNm': bcAcNm,
      'chRqSt': chRqSt,
      'cOprtn': cOprtn,
      'detail': detail.map((e) => e.toJson()).toList(),
    };
  }
}

class SaveChangeRequestDetail {
  final int? chRqCd;
  final String? chtype;
  final String? chvalu;

  SaveChangeRequestDetail({
    required this.chRqCd,
    required this.chtype,
    required this.chvalu,
  });

  Map<String?, dynamic> toJson() {
    return {'chRqCd': chRqCd, 'chtype': chtype, 'chvalu': chvalu};
  }
}
*/
