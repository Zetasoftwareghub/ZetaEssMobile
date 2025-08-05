import '../../../../models/listRights_model.dart';

class SalaryCertificateListModel {
  String? fromMonth;
  String? toMonth;
  String? purpose;
  String? id;

  SalaryCertificateListModel({
    this.fromMonth,
    this.toMonth,
    this.purpose,
    this.id,
  });

  factory SalaryCertificateListModel.fromJson(Map<String, dynamic> json) {
    return SalaryCertificateListModel(
      fromMonth: json['empName'].toString(),
      toMonth: json['lsnote'].toString(),
      purpose: json['lvpcarname'].toString(),
      id: json['dLsrdtf'].toString(),
    );
  }
}

class SubmittedSalaryCertificateResponse {
  final List<SalaryCertificateListModel> salaryCertificateList;
  final ListRightsModel listRights;

  SubmittedSalaryCertificateResponse({
    required this.salaryCertificateList,
    required this.listRights,
  });

  factory SubmittedSalaryCertificateResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final subList = (json['data']['subLst'] ?? []) as List<dynamic>;

    return SubmittedSalaryCertificateResponse(
      salaryCertificateList:
          subList.map((e) => SalaryCertificateListModel.fromJson(e)).toList(),
      listRights: ListRightsModel.fromJson(json['data']['rights'] ?? {}),
    );
  }
}

class SalaryCertificateListResponse {
  final SubmittedSalaryCertificateResponse submitted;
  final List<SalaryCertificateListModel> approved;
  final List<SalaryCertificateListModel> cancelled;
  final List<SalaryCertificateListModel> rejected;

  SalaryCertificateListResponse({
    required this.submitted,
    required this.approved,
    required this.cancelled,
    required this.rejected,
  });

  factory SalaryCertificateListResponse.fromJson(Map<String, dynamic> json) {
    return SalaryCertificateListResponse(
      submitted: SubmittedSalaryCertificateResponse.fromJson(json),
      approved:
          (json['appLst'] as List<dynamic>? ?? [])
              .map((e) => SalaryCertificateListModel.fromJson(e))
              .toList(),
      cancelled:
          (json['canLst'] as List<dynamic>? ?? [])
              .map((e) => SalaryCertificateListModel.fromJson(e))
              .toList(),
      rejected:
          (json['rejLst'] as List<dynamic>? ?? [])
              .map((e) => SalaryCertificateListModel.fromJson(e))
              .toList(),
    );
  }
}
