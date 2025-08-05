class ApproveSalaryCertificateListingModel {
  String? dateFrom;
  String? dateTo;
  String? name;
  String? id;

  ApproveSalaryCertificateListingModel({
    this.dateFrom,
    this.dateTo,
    this.id,
    this.name,
  });

  factory ApproveSalaryCertificateListingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ApproveSalaryCertificateListingModel(
      dateFrom: json["lsnote"].toString(),
      dateTo: json["lvpcarname"].toString(),
      name: json["empName"].toString(),
      id: json["dLsrdtf"].toString(),
    );
  }
}

class ApproveSalaryCertificateListResponse {
  final List<ApproveSalaryCertificateListingModel> submitted;
  final List<ApproveSalaryCertificateListingModel> approved;
  final List<ApproveSalaryCertificateListingModel> rejected;

  ApproveSalaryCertificateListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ApproveSalaryCertificateListResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] ?? {};

    return ApproveSalaryCertificateListResponse(
      submitted:
          (data['subLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveSalaryCertificateListingModel.fromJson(e))
              .toList(),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveSalaryCertificateListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveSalaryCertificateListingModel.fromJson(e))
              .toList(),
    );
  }
}
