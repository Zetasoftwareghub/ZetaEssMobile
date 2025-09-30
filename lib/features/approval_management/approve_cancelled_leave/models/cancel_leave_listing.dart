class ApproveCancelLeaveListingModel {
  final String employeeName;
  final String leaveDateFrom;
  final String leaveDateTo;
  final String lsslno;
  final String laslno;
  final String clslno;

  ApproveCancelLeaveListingModel({
    required this.employeeName,
    required this.leaveDateFrom,
    required this.leaveDateTo,
    required this.lsslno,
    required this.laslno,
    required this.clslno,
  });

  factory ApproveCancelLeaveListingModel.fromJson(Map<String, dynamic> json) {
    return ApproveCancelLeaveListingModel(
      employeeName: json['emname'] ?? '',
      leaveDateFrom: json['ladtfm'] ?? '',
      leaveDateTo: json['ladtto'] ?? '',
      lsslno: json['lsslno'] ?? '',
      laslno: json['laslno'] ?? '',
      clslno: json['clslno'] ?? '',
    );
  }
}

class ApproveCancelLeaveListResponse {
  final List<ApproveCancelLeaveListingModel> submitted;
  final List<ApproveCancelLeaveListingModel> approved;
  final List<ApproveCancelLeaveListingModel> rejected;

  ApproveCancelLeaveListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ApproveCancelLeaveListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ApproveCancelLeaveListResponse(
      submitted:
          (data['subLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveCancelLeaveListingModel.fromJson(e))
              .toList(),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveCancelLeaveListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveCancelLeaveListingModel.fromJson(e))
              .toList(),
    );
  }
}
