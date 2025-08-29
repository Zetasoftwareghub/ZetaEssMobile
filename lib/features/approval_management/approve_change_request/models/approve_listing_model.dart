class ApproveChangeRequestListResponseModel {
  final List<ApproveChangeRequestListModel> submitted;
  final List<ApproveChangeRequestListModel> approved;
  final List<ApproveChangeRequestListModel> rejected;

  ApproveChangeRequestListResponseModel({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ApproveChangeRequestListResponseModel.fromJson(List? data) {
    List<ApproveChangeRequestListModel> parse(int index) {
      if (data == null || data.length <= index || data[index] is! List) {
        return [];
      }
      return (data[index] as List)
          .whereType<Map<String, dynamic>>()
          .map((req) => ApproveChangeRequestListModel.fromJson(req))
          .toList();
    }

    return ApproveChangeRequestListResponseModel(
      submitted: parse(0),
      approved: parse(1),
      rejected: parse(2),
    );
  }
}

class ApproveChangeRequestListModel {
  final int requestCode; // chrqcd
  final String requestName; // chrqtp_text
  final String chrqst; // chrqtp_text
  final String employeeName; // emname
  final String employeeCode; // emcode
  final DateTime requestDate; // chrqdt

  ApproveChangeRequestListModel({
    required this.requestCode,
    required this.requestName,
    required this.chrqst,
    required this.employeeName,
    required this.employeeCode,
    required this.requestDate,
  });

  factory ApproveChangeRequestListModel.fromJson(Map<String, dynamic> json) {
    return ApproveChangeRequestListModel(
      requestCode: json['chrqcd'] ?? 0,
      requestName: json['chrqtp_text'] ?? '',
      chrqst: json['chrqtp'] ?? '', // TODO this is the reason for type
      employeeName: json['emname'] ?? '',
      employeeCode: json['emcode'].toString() ?? '',
      requestDate:
          json['chrqdt'] != null
              ? DateTime.parse(json['chrqdt'])
              : DateTime(1970),
    );
  }
}
