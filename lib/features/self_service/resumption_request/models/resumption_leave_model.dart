class ResumptionLeaveModel {
  String? dates;
  String? lsslno;
  String? noOfDays;
  String? laslno;
  String? lvtype;
  String? leavetype;
  String? dtNxtWrkDay;
  bool canChangeDate;

  ResumptionLeaveModel({
    this.dates,
    this.lsslno,
    this.noOfDays,
    this.laslno,
    this.lvtype,
    this.leavetype,
    this.dtNxtWrkDay,
    this.canChangeDate = false,
  });

  factory ResumptionLeaveModel.fromJson(
    Map<String, dynamic> json,
    canChangeDate,
  ) {
    return ResumptionLeaveModel(
      dates: json["dates"].toString(),
      lsslno: json["lsslno"].toString(),
      noOfDays: json["lsrndy"].toString(),
      laslno: json["laslno"].toString(),
      lvtype: json["lvtype"].toString(),
      leavetype: json["leavetype"].toString(),
      dtNxtWrkDay: json["dtNxtWrkDay"].toString(),
      canChangeDate: canChangeDate,
    );
  }
}
