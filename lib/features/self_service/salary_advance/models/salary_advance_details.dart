class SalaryAdvanceDetailsModel {
  final String dateFrom;
  final String amount;
  final String name;
  final String emcode;
  final String empId;
  final String subDate;
  final String note;
  final String year;
  final String month;
  final String appAmount;
  final String raapnt;
  final String lmComment;
  final String iRqmode;
  final String prevComment;
  final String appRejComment;

  SalaryAdvanceDetailsModel({
    required this.dateFrom,
    required this.amount,
    required this.name,
    required this.emcode,
    required this.empId,
    required this.subDate,
    required this.note,
    required this.year,
    required this.month,
    required this.appAmount,
    required this.raapnt,
    required this.lmComment,
    required this.iRqmode,
    required this.prevComment,
    required this.appRejComment,
  });
  factory SalaryAdvanceDetailsModel.fromJson(Map<String, dynamic> json) {
    return SalaryAdvanceDetailsModel(
      dateFrom: json["mnthNameYear"]?.toString() ?? '',
      amount: json["sRaamnt"]?.toString() ?? '',
      name: json["empName"]?.toString() ?? '',
      emcode: json["iEmcode"]?.toString() ?? '',
      empId: json["empId"]?.toString() ?? '',
      subDate: json["sRadate"]?.toString() ?? '',
      note: json["sRanote"]?.toString() ?? '',
      year: json['iRayear']?.toString() ?? '',
      month: json['iRamnth']?.toString() ?? '',
      appAmount: json['lRaappv']?.toString() ?? '',
      raapnt: json['raapnt']?.toString() ?? '',
      lmComment: json['lmComment']?.toString() ?? '',
      iRqmode: json['iRqmode']?.toString() ?? '',
      prevComment: json['prevComment']?.toString() ?? '',
      appRejComment: json['appRejComment']?.toString() ?? '',
    );
  }
}
