class ApproveExpenseClaimListingModel {
  String? id;
  String? emname;
  String? monthYear;
  String? amount;

  ApproveExpenseClaimListingModel({
    this.id,
    this.emname,
    this.amount,
    this.monthYear,
  });

  factory ApproveExpenseClaimListingModel.fromJson(Map<String, dynamic> json) {
    return ApproveExpenseClaimListingModel(
      id: json['iClslno'].toString(),
      emname: json['empName'].toString(),
      monthYear: json['monthYear'].toString(),
      amount: json['sClamnt'].toString(),
    );
  }
}

class ApproveExpenseClaimListResponse {
  final List<ApproveExpenseClaimListingModel> submitted;
  final List<ApproveExpenseClaimListingModel> approved;
  final List<ApproveExpenseClaimListingModel> rejected;

  ApproveExpenseClaimListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ApproveExpenseClaimListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return ApproveExpenseClaimListResponse(
      submitted:
          (data['subLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveExpenseClaimListingModel.fromJson(e))
              .toList(),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveExpenseClaimListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveExpenseClaimListingModel.fromJson(e))
              .toList(),
    );
  }
}
