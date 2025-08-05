import '../../../../models/listRights_model.dart';

class ResumptionListingModel {
  int? reslno;
  String? redate;
  String? lsrdtf;
  String? lsrdtt;
  String? emname;
  String? empname;

  ResumptionListingModel({
    this.reslno,
    this.redate,
    this.lsrdtf,
    this.lsrdtt,
    this.emname,
    this.empname,
  });

  factory ResumptionListingModel.fromJson(Map<String, dynamic> json) {
    return ResumptionListingModel(
      reslno: json["reslno"] ?? 0,
      redate: json["redate"]?.toString(),
      lsrdtf: json["lsrdtf"]?.toString(),
      lsrdtt: json["lsrdtt"]?.toString(),
      emname: json['emname']?.toString(),
      empname: json['empname']?.toString(),
    );
  }
}

class ResumptionListResponse {
  final SubmittedResumptionResponse submitted;
  final List<ResumptionListingModel> approved;
  final List<ResumptionListingModel> rejected;

  ResumptionListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ResumptionListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return ResumptionListResponse(
      submitted: SubmittedResumptionResponse.fromJson(json),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => ResumptionListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => ResumptionListingModel.fromJson(e))
              .toList(),
    );
  }
}

class SubmittedResumptionResponse {
  final List<ResumptionListingModel> resumptionList;
  final ListRightsModel listRights;

  SubmittedResumptionResponse({
    required this.resumptionList,
    required this.listRights,
  });

  factory SubmittedResumptionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final subList = (data['subLst'] ?? []) as List<dynamic>;

    return SubmittedResumptionResponse(
      resumptionList:
          subList.map((e) => ResumptionListingModel.fromJson(e)).toList(),
      listRights: ListRightsModel.fromJson(data['rights'] ?? {}),
    );
  }
}
