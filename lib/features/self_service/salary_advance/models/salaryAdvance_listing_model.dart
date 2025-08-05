import '../../../../models/listRights_model.dart';

class SalaryAdvanceListingModel {
  String? date;
  String? amount;
  String? approvedAmount;
  String? note;
  String? id;
  String? empName;

  SalaryAdvanceListingModel({
    this.amount,
    this.date,
    this.note,
    this.id,
    this.approvedAmount,
    this.empName,
  });

  factory SalaryAdvanceListingModel.fromJson(Map<String, dynamic> json) {
    return SalaryAdvanceListingModel(
      date: json['sRadate']?.toString(), // lowercase 'sRadate'
      amount: json['sRaamnt']?.toString(), // lowercase 'sRaamnt'
      note: json['sRanote']?.toString(), // lowercase 'sRanote'
      id: json['iRaslno']?.toString(), // lowercase 'iRaslno'
      approvedAmount: json['lRaappv']?.toString(), // lowercase 'lRaappv'
      empName: json['empName']?.toString(), // optional: still handled
    );
  }
}

class SubmittedSalaryAdvanceResponse {
  final List<SalaryAdvanceListingModel> salaryAdvanceList;
  final ListRightsModel listRights;

  SubmittedSalaryAdvanceResponse({
    required this.salaryAdvanceList,
    required this.listRights,
  });

  factory SubmittedSalaryAdvanceResponse.fromJson(Map<String, dynamic> json) {
    final subList = (json['data']['subLst'] ?? []) as List<dynamic>;

    return SubmittedSalaryAdvanceResponse(
      salaryAdvanceList:
          subList.map((e) => SalaryAdvanceListingModel.fromJson(e)).toList(),
      listRights: ListRightsModel.fromJson(json['data']['rights'] ?? {}),
    );
  }
}

class SalaryAdvanceListResponse {
  final SubmittedSalaryAdvanceResponse submitted;
  final List<SalaryAdvanceListingModel> approved;
  final List<SalaryAdvanceListingModel> cancelled;
  final List<SalaryAdvanceListingModel> rejected;

  SalaryAdvanceListResponse({
    required this.submitted,
    required this.approved,
    required this.cancelled,
    required this.rejected,
  });

  factory SalaryAdvanceListResponse.fromJson(Map<String, dynamic> json) {
    return SalaryAdvanceListResponse(
      submitted: SubmittedSalaryAdvanceResponse.fromJson(json),
      approved:
          (json['appLst'] as List<dynamic>? ?? [])
              .map((e) => SalaryAdvanceListingModel.fromJson(e))
              .toList(),
      cancelled:
          (json['canLst'] as List<dynamic>? ?? [])
              .map((e) => SalaryAdvanceListingModel.fromJson(e))
              .toList(),
      rejected:
          (json['rejLst'] as List<dynamic>? ?? [])
              .map((e) => SalaryAdvanceListingModel.fromJson(e))
              .toList(),
    );
  }
}
