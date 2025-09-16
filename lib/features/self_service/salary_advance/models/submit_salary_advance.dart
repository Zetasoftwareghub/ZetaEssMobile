class SubmitSalaryAdvanceModel {
  final String? suconn;
  final int emcode;
  final String sucode;
  final String? username;
  final int iSaid;
  final String? monthyear;
  final String? reqdate;
  final String? note;
  final String? amount;
  final String? url;
  final int cocode;
  final int paymentMode;
  final String? baseDirectory;

  SubmitSalaryAdvanceModel({
    required this.suconn,
    required this.sucode,
    required this.emcode,
    required this.username,
    required this.iSaid,
    required this.monthyear,
    required this.reqdate,
    required this.note,
    required this.amount,
    required this.url,
    required this.cocode,
    required this.paymentMode,
    required this.baseDirectory,
  });

  Map<String?, dynamic> toJson() {
    return {
      "suconn": suconn,
      "sucode": sucode,

      "emcode": emcode,
      "username": username,
      "iSaid": iSaid,
      "monthyear": monthyear,
      "reqdate": reqdate,
      "note": note,
      "amount": amount,
      "url": url,
      "cocode": cocode,
      "paymentMode": paymentMode,
      "baseDirectory": baseDirectory,
    };
  }
}
