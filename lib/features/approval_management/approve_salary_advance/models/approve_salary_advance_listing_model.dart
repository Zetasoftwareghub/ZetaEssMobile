class ApproveSalaryAdvanceListingModel {
  String? dateFrom;
  String? dateTo;
  String? name;
  String? id;
  String? amount;

  ApproveSalaryAdvanceListingModel({
    this.dateFrom,
    this.dateTo,
    this.id,
    this.name,
    this.amount,
  });

  factory ApproveSalaryAdvanceListingModel.fromJson(Map<String, dynamic> json) {
    return ApproveSalaryAdvanceListingModel(
      dateFrom: json["lsnote"].toString(),
      amount: json["lvpcarname"].toString(),
      name: json["empName"].toString(),
      id: json["dLsrdtf"].toString(),
    );
  }
}

class ApproveSalaryAdvanceListResponse {
  final List<ApproveSalaryAdvanceListingModel> submitted;
  final List<ApproveSalaryAdvanceListingModel> approved;
  final List<ApproveSalaryAdvanceListingModel> rejected;

  ApproveSalaryAdvanceListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ApproveSalaryAdvanceListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return ApproveSalaryAdvanceListResponse(
      submitted:
          (data['subLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveSalaryAdvanceListingModel.fromJson(e))
              .toList(),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveSalaryAdvanceListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveSalaryAdvanceListingModel.fromJson(e))
              .toList(),
    );
  }
}
