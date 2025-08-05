class ApproveResumptionListingModel {
  int? reslno;
  String? redate;
  String? lsrdtf;
  String? lsrdtt;
  String? emname;
  String? empname;

  ApproveResumptionListingModel({
    this.reslno,
    this.redate,
    this.lsrdtf,
    this.lsrdtt,
    this.emname,
    this.empname,
  });

  factory ApproveResumptionListingModel.fromJson(Map<String, dynamic> json) {
    return ApproveResumptionListingModel(
      reslno: json["reslno"] ?? 0,
      redate: json["redate"]?.toString(),
      lsrdtf: json["lsrdtf"]?.toString(),
      lsrdtt: json["lsrdtt"]?.toString(),
      emname: json['emname']?.toString(),
      empname: json['emname']?.toString(),
    );
  }
}

class ApproveResumptionListResponse {
  final List<ApproveResumptionListingModel> submitted;
  final List<ApproveResumptionListingModel> approved;
  final List<ApproveResumptionListingModel> rejected;

  ApproveResumptionListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ApproveResumptionListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return ApproveResumptionListResponse(
      submitted:
          (data['subLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveResumptionListingModel.fromJson(e))
              .toList(),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveResumptionListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveResumptionListingModel.fromJson(e))
              .toList(),
    );
  }
}
