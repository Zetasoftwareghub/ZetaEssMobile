import '../../../../core/utils.dart';
import '../../../../models/listRights_model.dart';

class SalaryCertificateListModel {
  String? fromMonth;
  String? toMonth;
  String? purpose;
  String? id;
  String? status;

  SalaryCertificateListModel({
    this.fromMonth,
    this.toMonth,
    this.purpose,
    this.id,
    this.status,
  });

  factory SalaryCertificateListModel.fromJson(Map<String, dynamic> json) {
    return SalaryCertificateListModel(
      fromMonth: json['empName'].toString(),
      toMonth: json['lsnote'].toString(),
      purpose: json['lvpcarname'].toString(),
      id: json['dLsrdtf'].toString(),
      status: json['rqEmname'].toString(),
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
  final List<SalaryCertificateListModel> rejected;

  SalaryCertificateListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory SalaryCertificateListResponse.fromJson(Map<String, dynamic> json) {
    return SalaryCertificateListResponse(
      submitted: SubmittedSalaryCertificateResponse.fromJson(json),
      approved:
          (json['data']['appLst'] as List<dynamic>? ?? [])
              .map((e) => SalaryCertificateListModel.fromJson(e))
              .toList(),

      rejected:
          (json['data']['rejLst'] as List<dynamic>? ?? [])
              .map((e) => SalaryCertificateListModel.fromJson(e))
              .toList(),
    );
  }
}
