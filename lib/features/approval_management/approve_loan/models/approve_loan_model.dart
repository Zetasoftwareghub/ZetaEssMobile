class ApproveLoanModel {
  final String? suconn, sucode;
  final String? aprDate;
  final String? reqDate;
  final double amount;
  final String? username;
  final int? lqslno;
  final int? reqemcode;
  final int? emcode;
  final String? comment;
  final String? aprflg;

  ApproveLoanModel({
    required this.suconn,
    required this.sucode,
    required this.aprDate,
    required this.reqDate,
    required this.amount,
    required this.username,
    required this.lqslno,
    required this.reqemcode,
    required this.emcode,
    required this.comment,
    required this.aprflg,
  });

  Map<String?, dynamic> toJson() {
    return {
      "sucode": sucode,
      'suconn': suconn,
      'aprDate': aprDate,
      'reqDate': reqDate,
      'amount': amount,
      'username': username,
      'lqslno': lqslno,
      'reqemcode': reqemcode,
      'emcode': emcode,
      'comment': comment,
      'aprflg': aprflg,
      'hfemcode': reqemcode, //saru says this and reqemcodeare same so done this
    };
  }
}
