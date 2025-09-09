class CancelLeaveModel {
  final String employeeId; // "eminid": "VI01"
  final String employeeName; // "emname": "John Wick"
  final String leaveDateFrom; // "dlsrdtf": "17/03/2024"
  final String leaveDateTo; // "dlsrdtt": "17/03/2024"
  final String submittedDate; // "dlsdate": "10/01/2024"
  final String approvedDate; // "dLadate": "29/04/2024"
  final String totalLeaves; // "llsrndy": "1.00"
  final String leaveTypeCode; // "ltcode": "9"
  final String employeeCode; // "emcode": "2078"
  final String lmComment; // "lmComment": ""
  final String prevComment; // "prevComment": ""

  CancelLeaveModel({
    required this.employeeId,
    required this.employeeName,
    required this.leaveDateFrom,
    required this.leaveDateTo,
    required this.submittedDate,
    required this.approvedDate,
    required this.totalLeaves,
    required this.leaveTypeCode,
    required this.employeeCode,
    required this.lmComment,
    required this.prevComment,
  });

  factory CancelLeaveModel.fromJson(Map<String, dynamic> json) {
    return CancelLeaveModel(
      employeeId: json['eminid'] ?? '',
      employeeName: json['emname'] ?? '',
      leaveDateFrom: json['dlsrdtf'] ?? '',
      leaveDateTo: json['dlsrdtt'] ?? '',
      submittedDate: json['dlsdate'] ?? '',
      approvedDate: json['dLadate'] ?? '',
      totalLeaves: json['llsrndy'] ?? '',
      leaveTypeCode: json['ltcode'] ?? '',
      employeeCode: json['emcode'] ?? '',
      lmComment: json['lmComment'] ?? '',
      prevComment: json['prevComment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eminid': employeeId,
      'emname': employeeName,
      'dlsrdtf': leaveDateFrom,
      'dlsrdtt': leaveDateTo,
      'dlsdate': submittedDate,
      'dLadate': approvedDate,
      'llsrndy': totalLeaves,
      'ltcode': leaveTypeCode,
      'emcode': employeeCode,
      'lmComment': lmComment,
      'prevComment': prevComment,
    };
  }
}
