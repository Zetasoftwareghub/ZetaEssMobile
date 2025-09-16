class LoanSubmitRequestModel {
  final String? suconn;
  final String? sucode;
  final int emcode;
  final int lntype;
  final String? note;
  final String amount;
  final String? reqdate;
  final String? username;
  final int paymentperiod;
  final String? deductionstartdate;
  final String? mediafile;
  final String? mediaExtension;
  final int loid;
  final String? baseDirectory;

  LoanSubmitRequestModel({
    required this.suconn,
    required this.sucode,
    required this.emcode,
    required this.lntype,
    required this.note,
    required this.amount,
    required this.reqdate,
    required this.username,
    required this.paymentperiod,
    required this.deductionstartdate,
    required this.mediafile,
    required this.mediaExtension,
    required this.loid,
    required this.baseDirectory,
  });

  Map<String?, dynamic> toJson() => {
    "suconn": suconn,
    "sucode": sucode,

    "emcode": emcode,
    "lntype": lntype,
    "note": note,
    "amount": amount,
    "reqdate": reqdate,
    "username": username,
    "paymentperiod": paymentperiod,
    "deductionstartdate": deductionstartdate,
    "mediafile": mediafile ?? '',
    "mediaExtension": mediaExtension ?? '',
    "loid": loid,
    "baseDirectory": baseDirectory,
  };
}
