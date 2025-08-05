class LmAttendanceRegularization {
  String? empName;
  String? dLsrdtf;
  int? iLsslno;
  String? sEmpid;

  LmAttendanceRegularization({
    this.empName,
    this.dLsrdtf,
    this.iLsslno,
    this.sEmpid,
  });

  factory LmAttendanceRegularization.fromJson(Map<String, dynamic> json) {
    return LmAttendanceRegularization(
      empName: json["empName"]?.toString(),
      dLsrdtf: json["dLsrdtf"]?.toString(),
      iLsslno:
          json["iLsslno"] is int
              ? json["iLsslno"]
              : int.tryParse(json["iLsslno"].toString()),
      sEmpid: json["sEmpid"]?.toString(),
    );
  }
}

class LMAttendanceRegularizationApproveDetails {
  String? empName;
  String? dLsrdtf;
  String? dLsdate;
  String? lsnote;
  String? subname;
  String? lmComment;
  String? prevComment;

  LMAttendanceRegularizationApproveDetails({
    this.empName,
    this.dLsrdtf,
    this.dLsdate,
    this.lsnote,
    this.subname,
    this.lmComment,
    this.prevComment,
  });

  factory LMAttendanceRegularizationApproveDetails.fromJson(
    Map<String, dynamic> json,
  ) {
    return LMAttendanceRegularizationApproveDetails(
      empName: json["empName"]?.toString(),
      dLsrdtf: json["dLsrdtf"]?.toString(),
      dLsdate: json["dLsdate"]?.toString(),
      lsnote: json["lsnote"]?.toString(),
      subname: json["subname"]?.toString(),
      lmComment: json["lmComment"]?.toString(),
      prevComment: json["prevComment"]?.toString(),
    );
  }
}
