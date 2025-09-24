import '../../../../models/listRights_model.dart';

class LoanListResponse {
  final List<LoanListModel> approved;
  final List<LoanListModel> rejected;
  final SubmittedLoanResponse submitted;

  LoanListResponse({
    required this.approved,
    required this.rejected,
    required this.submitted,
  });

  factory LoanListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List;
    return LoanListResponse(
      submitted: SubmittedLoanResponse.fromJson(json),

      approved:
          (data[0] as List).map((e) => LoanListModel.fromJson(e)).toList(),
      rejected:
          (data[1] as List).map((e) => LoanListModel.fromJson(e)).toList(),
    );
  }
}

class SubmittedLoanResponse {
  final List<LoanListModel> loanList;
  final ListRightsModel listRights;

  SubmittedLoanResponse({required this.loanList, required this.listRights});

  factory SubmittedLoanResponse.fromJson(Map<String, dynamic> json) {
    final subList = (json['data'][2] ?? []) as List<dynamic>;

    return SubmittedLoanResponse(
      loanList: subList.map((e) => LoanListModel.fromJson(e)).toList(),
      listRights: ListRightsModel.fromJson(json['rights'] ?? {}),
    );
  }
}

class LoanListModel {
  final String loanId;
  final String? submittedDate;
  final double loanAmount;
  final String loanType;
  final double? lqappv;
  final int emcode;
  final String note;
  final String lqfmap;
  final String lqadap;
  final String lqstat;
  final int lqapfg;
  final String? loanStatus;
  final String? lmname;
  final String crcode;
  final String? lqapnt;
  final DateTime? loanDeductionStartDate;
  final int lqrpmn;
  final DateTime lqdsdt;
  final int crdcml;
  final String emname;
  final String eminid, requestEmpname;

  LoanListModel({
    required this.loanId,
    required this.submittedDate,
    required this.loanAmount,
    required this.loanType,
    this.lqappv,
    required this.emcode,
    required this.note,
    required this.lqfmap,
    required this.lqadap,
    required this.lqstat,
    required this.lqapfg,
    this.loanStatus,
    this.lmname,
    required this.crcode,
    this.lqapnt,
    required this.requestEmpname,
    this.loanDeductionStartDate,
    required this.lqrpmn,
    required this.lqdsdt,
    required this.crdcml,
    required this.emname,
    required this.eminid,
  });

  factory LoanListModel.fromJson(Map<String, dynamic> json) {
    return LoanListModel(
      loanId: json['lqslno']?.toString() ?? '',
      submittedDate: json['lqdate']?.toString(),
      loanAmount:
          (json['lqamnt'] is num) ? (json['lqamnt'] as num).toDouble() : 0.0,
      loanType: json['loname']?.toString() ?? '',
      lqappv:
          (json['lqappv'] is num) ? (json['lqappv'] as num).toDouble() : null,
      emcode:
          json['emcode'] is int
              ? json['emcode']
              : int.tryParse(json['emcode']?.toString() ?? '0') ?? 0,
      note: json['lqnote']?.toString() ?? '',
      lqfmap: json['lqfmap']?.toString() ?? '',
      lqadap: json['lqadap']?.toString() ?? '',
      lqstat: json['lqstat']?.toString() ?? '',
      lqapfg:
          json['lqapfg'] is int
              ? json['lqapfg']
              : int.tryParse(json['lqapfg']?.toString() ?? '0') ?? 0,
      loanStatus:
          (json['lmname'] ?? "").toString().isEmpty
              ? json['apstat']?.toString()
              : json['lmname']?.toString(),
      lmname: json['lmname']?.toString(),
      crcode: json['crcode']?.toString() ?? '',
      lqapnt: json['lqapnt']?.toString(),
      loanDeductionStartDate:
          json['lqapdt'] != null ? DateTime.tryParse(json['lqapdt']) : null,
      lqrpmn:
          json['lqrpmn'] is int
              ? json['lqrpmn']
              : int.tryParse(json['lqrpmn']?.toString() ?? '0') ?? 0,
      lqdsdt:
          json['lqdsdt'] != null
              ? DateTime.tryParse(json['lqdsdt']) ?? DateTime(2000)
              : DateTime(2000),
      crdcml:
          json['crdcml'] is int
              ? json['crdcml']
              : int.tryParse(json['crdcml']?.toString() ?? '0') ?? 0,
      emname: json['emname']?.toString() ?? '',
      eminid: json['eminid']?.toString() ?? '',
      requestEmpname: json['rqempname']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lqslno': loanId,
      'submittedDate': submittedDate,
      'lqamnt': loanAmount,
      'loanType': loanType,
      'lqappv': lqappv,
      'emcode': emcode,
      'note': note,
      'lqfmap': lqfmap,
      'lqadap': lqadap,
      'lqstat': lqstat,
      'lqapfg': lqapfg,
      'loanStatus': loanStatus,
      'lmname': lmname,
      'crcode': crcode,
      'lqapnt': lqapnt,
      'loanDeductionStartDate': loanDeductionStartDate?.toIso8601String(),
      'lqrpmn': lqrpmn,
      'lqdsdt': lqdsdt.toIso8601String(),
      'crdcml': crdcml,
      'emname': emname,
      'eminid': eminid,
    };
  }
}
