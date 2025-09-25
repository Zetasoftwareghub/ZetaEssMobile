class LoanDetailModel {
  final int accCode;
  final int loanSerialNo;
  final String submittedDate;
  final String approvedDate;
  final int employeeCode;
  final int LoanTypeCode;
  final int fromCode;
  final int hrCode;
  final double loanAmount;
  final double approvedAmount;
  final String note;
  final String fmap;
  final String status;
  final int approvalFlag;
  final int approverId;
  final String adap;
  final String approverNote;
  final int napId;
  final int approvedMonths;
  final String repaymentStartDate;
  final String? filePath;
  final int requestEmployeeCode;
final String? previousComment, lmComment, approvalRejectionComment;

  LoanDetailModel({
    required this.accCode,
    required this.loanSerialNo,
    required this.submittedDate,
    required this.approvedDate,
    required this.employeeCode,
    required this.LoanTypeCode,
    required this.fromCode,
    required this.hrCode,
    required this.loanAmount,
    required this.approvedAmount,
    required this.note,
    required this.fmap,
    required this.status,
    required this.approvalFlag,
    required this.approverId,
    required this.adap,
    required this.approverNote,
    required this.napId,
    required this.approvedMonths,
    required this.repaymentStartDate,
    required this.requestEmployeeCode,
    required this.filePath,
    required this.lmComment,
    required this.previousComment,
    required this.approvalRejectionComment,
  });

  factory LoanDetailModel.fromJson(Map<String, dynamic> json) {
    return LoanDetailModel(
      accCode: json['iAccode'],
      loanSerialNo: json['iLqslno'],
      submittedDate: json['sLqdate'] ?? '',
      approvedDate: json['sLqapdt'] ?? '',
      employeeCode: json['iEmcode'],
      LoanTypeCode: json['iLocode'],
      fromCode: json['iLqfmcd'],
      hrCode: json['iLqhrcd'],
      loanAmount: (json['lLqamnt'] as num).toDouble(),
      approvedAmount: (json['lLqappv'] as num).toDouble(),
      note: json['sLqnote'] ?? '',
      fmap: json['sLqfmap'] ?? '',
      status: json['sLqstat'] ?? '',
      approvalFlag: json['iLqapfg'],
      approverId: json['iAprlid'],
      adap: json['lqadap'] ?? '',
      approverNote: json['lqapnt'] ?? '',
      napId: json['lnapid'],
      approvedMonths: json['iLqrpmn'],
      repaymentStartDate: json['sLqdsdt'] ?? '',
      requestEmployeeCode: json['rqemcd'],
      filePath: json['lqdctp'],
      previousComment: json['prevComment'] ?? '',
      lmComment: json['lmComment'] ?? '',
      approvalRejectionComment: json['appRejComment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iAccode': accCode,
      'iLqslno': loanSerialNo,
      'sLqdate': submittedDate,
      'sLqapdt': approvedDate,
      'iEmcode': employeeCode,
      'iLocode': LoanTypeCode,
      'iLqfmcd': fromCode,
      'iLqhrcd': hrCode,
      'lLqamnt': loanAmount,
      'lLqappv': approvedAmount,
      'sLqnote': note,
      'sLqfmap': fmap,
      'sLqstat': status,
      'iLqapfg': approvalFlag,
      'iAprlid': approverId,
      'lqadap': adap,
      'lqapnt': approverNote,
      'lnapid': napId,
      'iLqrpmn': approvedMonths,
      'sLqdsdt': repaymentStartDate,
      'rqemcd': requestEmployeeCode,
    };
  }
}
