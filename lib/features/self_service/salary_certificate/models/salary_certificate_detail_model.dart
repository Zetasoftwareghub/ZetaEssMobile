class SalaryCertificateDetailsModel {
  final String? submissionDate; // sRqdate
  final String? fromMonth; // mnyrFrm
  final String? toMonth; // mnyrTo
  final String? employeeCode; // empId
  final String? employeeId; // iEmcode
  final String? employeeName; // empName
  final String? purpose; // sRqpurp
  final String? remarks; // sRqnote
  final String? accountName; // rqbknm
  final String? note; // sRqnote (same as remarks)
  final String? requestedAppointment; // rqapnt
  final String? lineManagerComment; // lmComment
  final String? previousComment; // prevComment
  final String? approvalOrRejectionComment; // appRejComment

  SalaryCertificateDetailsModel({
    this.submissionDate,
    this.fromMonth,
    this.toMonth,
    this.employeeCode,
    this.employeeId,
    this.employeeName,
    this.purpose,
    this.remarks,
    this.accountName,
    this.note,
    this.requestedAppointment,
    this.lineManagerComment,
    this.previousComment,
    this.approvalOrRejectionComment,
  });

  factory SalaryCertificateDetailsModel.fromJson(Map<String, dynamic> json) {
    return SalaryCertificateDetailsModel(
      employeeName: json["empName"]?.toString(),
      employeeId: json["iEmcode"]?.toString(),
      employeeCode: json["empId"]?.toString(),
      submissionDate: json["sRqdate"]?.toString(),
      fromMonth: json["mnyrFrm"]?.toString(),
      toMonth: json["mnyrTo"]?.toString(),
      purpose: json["sRqpurp"]?.toString(),
      remarks: json["sRqnote"]?.toString(),
      note: json["sRqnote"]?.toString(),
      accountName: json["rqbknm"]?.toString(),
      requestedAppointment: json["rqapnt"]?.toString(),
      lineManagerComment: json["lmComment"]?.toString(),
      previousComment: json["prevComment"]?.toString(),
      approvalOrRejectionComment: json["appRejComment"]?.toString(),
    );
  }
}
