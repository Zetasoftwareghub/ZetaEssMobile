class SubmitSalaryCertificateModel {
  final String? suconn;
  final String? sucode;
  final int emcode;
  final String? username;
  final int iSrid;
  final String? frommonth;
  final String? tomonth;
  final String? purpose;
  final String? reqdate;
  final String? rmrks;
  final String? addressname;
  final String? url;
  final int cocode;
  final String? baseDirectory;

  SubmitSalaryCertificateModel({
    required this.suconn,
    required this.sucode,
    required this.emcode,
    required this.username,
    required this.iSrid,
    required this.frommonth,
    required this.tomonth,
    required this.purpose,
    required this.reqdate,
    required this.rmrks,
    required this.addressname,
    required this.url,
    required this.cocode,
    required this.baseDirectory,
  });

  Map<String?, dynamic> toJson() {
    return {
      "sucode": sucode,
      'suconn': suconn,
      'emcode': emcode,
      'username': username,
      'iSrid': iSrid,
      'frommonth': frommonth,
      'tomonth': tomonth,
      'purpose': purpose,
      'reqdate': reqdate,
      'rmrks': rmrks,
      'addressname': addressname,
      'url': url,
      'cocode': cocode,
      'baseDirectory': baseDirectory,
    };
  }
}
