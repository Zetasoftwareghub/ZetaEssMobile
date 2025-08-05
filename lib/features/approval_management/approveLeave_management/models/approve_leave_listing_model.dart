class LeaveApprovalListingModel {
  String? dateFrom;
  String? dateTo;
  String? leaveDays;
  String? leaveId;
  String? user;

  LeaveApprovalListingModel({
    this.dateFrom,
    this.dateTo,
    this.leaveDays,
    this.leaveId,
    this.user,
  });

  factory LeaveApprovalListingModel.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalListingModel(
      dateFrom: json["dLadtfm"]?.toString(),
      dateTo: json["dLadtto"]?.toString(),
      leaveDays: json["lLandys"]?.toString(),
      leaveId: json["iLsslno"]?.toString(),
      user: json["sLauser"]?.toString(),
    );
  }
}

class LeaveApprovalListResponse {
  final List<LeaveApprovalListingModel> submitted;
  final List<LeaveApprovalListingModel> approved;
  final List<LeaveApprovalListingModel> rejected;

  LeaveApprovalListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory LeaveApprovalListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return LeaveApprovalListResponse(
      submitted:
          (data['subLst'] as List<dynamic>? ?? [])
              .map((e) => LeaveApprovalListingModel.fromJson(e))
              .toList(),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => LeaveApprovalListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => LeaveApprovalListingModel.fromJson(e))
              .toList(),
    );
  }
}
