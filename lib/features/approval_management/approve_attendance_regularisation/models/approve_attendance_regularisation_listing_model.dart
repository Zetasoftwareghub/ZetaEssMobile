class ApproveAttendanceRegularisationListingModel {
  int? id;
  String? regularisationDate;
  String? employeeName;
  String? empId;

  ApproveAttendanceRegularisationListingModel({
    this.id,
    this.regularisationDate,
    this.employeeName,
    this.empId,
  });

  factory ApproveAttendanceRegularisationListingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ApproveAttendanceRegularisationListingModel(
      employeeName: json["empName"].toString(),
      regularisationDate: json["dLsrdtf"].toString(),
      id: json["iLsslno"],
      empId: json["sEmpid"].toString(), //TODO check
    );
  }
}

class ApproveAttendanceRegularisationListResponse {
  final List<ApproveAttendanceRegularisationListingModel> submitted;
  final List<ApproveAttendanceRegularisationListingModel> approved;
  final List<ApproveAttendanceRegularisationListingModel> rejected;

  ApproveAttendanceRegularisationListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ApproveAttendanceRegularisationListResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] ?? {};

    return ApproveAttendanceRegularisationListResponse(
      submitted:
          (data['subLst'] as List<dynamic>? ?? [])
              .map(
                (e) => ApproveAttendanceRegularisationListingModel.fromJson(e),
              )
              .toList(),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map(
                (e) => ApproveAttendanceRegularisationListingModel.fromJson(e),
              )
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map(
                (e) => ApproveAttendanceRegularisationListingModel.fromJson(e),
              )
              .toList(),
    );
  }
}
