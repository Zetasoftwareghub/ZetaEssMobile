class ApproveSchoolingAllowanceListingModel {
  int? allowanceId;
  String? allowanceDate;
  String? allowanceType;
  String? applicantName;
  String? amount;

  ApproveSchoolingAllowanceListingModel({
    this.allowanceId,
    this.allowanceDate,
    this.allowanceType,
    this.applicantName,
    this.amount,
  });

  factory ApproveSchoolingAllowanceListingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ApproveSchoolingAllowanceListingModel(
      allowanceId: json["allowanceId"] ?? 0,
      allowanceDate: json["allowanceDate"]?.toString(),
      allowanceType: json["allowanceType"]?.toString(),
      applicantName: json['applicantName']?.toString(),
      amount: json['amount']?.toString(),
    );
  }
}

class ApproveSchoolingAllowanceListResponse {
  final List<ApproveSchoolingAllowanceListingModel> submitted;
  final List<ApproveSchoolingAllowanceListingModel> approved;
  final List<ApproveSchoolingAllowanceListingModel> rejected;

  ApproveSchoolingAllowanceListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ApproveSchoolingAllowanceListResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] ?? {};

    return ApproveSchoolingAllowanceListResponse(
      submitted:
          (data['subLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveSchoolingAllowanceListingModel.fromJson(e))
              .toList(),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveSchoolingAllowanceListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveSchoolingAllowanceListingModel.fromJson(e))
              .toList(),
    );
  }
}
