class ApproveLieuDayListingModel {
  String? lieuDayId;
  String? lieuDayDate;
  String? employeeName;
  String? status;

  ApproveLieuDayListingModel({
    this.lieuDayId,
    this.lieuDayDate,
    this.employeeName,
    this.status,
  });

  factory ApproveLieuDayListingModel.fromJson(Map<String, dynamic> json) {
    return ApproveLieuDayListingModel(
      lieuDayId: json["rqldcode"] ?? '0',
      lieuDayDate: json["ludate"]?.toString(),
      employeeName: json['rqempname']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class ApproveLieuDayListResponse {
  final List<ApproveLieuDayListingModel> submitted;
  final List<ApproveLieuDayListingModel> approved;
  final List<ApproveLieuDayListingModel> rejected;

  ApproveLieuDayListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ApproveLieuDayListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return ApproveLieuDayListResponse(
      submitted:
          (data['subLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveLieuDayListingModel.fromJson(e))
              .toList(),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveLieuDayListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveLieuDayListingModel.fromJson(e))
              .toList(),
    );
  }
}
