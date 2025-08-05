class LieuDayDetailsModel {
  final String requestCode;
  final String lieuDate;
  final String type;
  final String fromTime;
  final String toTime;
  final String approverNotes;
  final String attachmentUrl;
  final String remark;
  final String employeeId;
  final String employeeName;
  final String department;
  final String designation;
  final String lineManager;
  final String dateOfJoining;
  final String division;
  final String category;
  final String previousComment;
  final String lineManagerComment;
  final String approvalRejectionComment;

  LieuDayDetailsModel({
    required this.requestCode,
    required this.lieuDate,
    required this.type,
    required this.fromTime,
    required this.toTime,
    required this.approverNotes,
    required this.attachmentUrl,
    required this.remark,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.designation,
    required this.lineManager,
    required this.dateOfJoining,
    required this.division,
    required this.category,
    required this.previousComment,
    required this.lineManagerComment,
    required this.approvalRejectionComment,
  });

  factory LieuDayDetailsModel.fromJson(Map<String, dynamic> json) {
    return LieuDayDetailsModel(
      requestCode: json['rqldcode'] ?? '',
      lieuDate: json['ludate'] ?? '',
      type: json['type'] ?? '',
      fromTime: json['frmtm'] ?? '',
      toTime: json['totm'] ?? '',
      approverNotes: json['apnotes'] ?? '',
      attachmentUrl: json['luatt'] ?? '',
      remark: json['remark'] ?? '',
      employeeId: json['employeeid'] ?? '',
      employeeName: json['employeename'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
      lineManager: json['linemanager'] ?? '',
      dateOfJoining: json['dojn'] ?? '',
      division: json['divisionname'] ?? '',
      category: json['categoryname'] ?? '',
      previousComment: json['prevComment'] ?? '',
      lineManagerComment: json['lmComment'] ?? '',
      approvalRejectionComment: json['appRejComment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rqldcode': requestCode,
      'ludate': lieuDate,
      'type': type,
      'frmtm': fromTime,
      'totm': toTime,
      'apnotes': approverNotes,
      'luatt': attachmentUrl,
      'remark': remark,
      'employeeid': employeeId,
      'employeename': employeeName,
      'department': department,
      'designation': designation,
      'linemanager': lineManager,
      'dojn': dateOfJoining,
      'divisionname': division,
      'categoryname': category,
      'prevComment': previousComment,
      'lmComment': lineManagerComment,
      'appRejComment': approvalRejectionComment,
    };
  }
}
