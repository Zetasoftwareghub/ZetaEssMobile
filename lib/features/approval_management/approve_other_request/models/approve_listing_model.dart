class ApproveOtherRequestListingModel {
  String? date;
  String? name;
  String? requestName;
  String? primaryKey;
  String? rteant;
  int? rqtmcd;

  ApproveOtherRequestListingModel({
    this.date,
    this.name,
    this.requestName,
    this.primaryKey,
    this.rteant,
    this.rqtmcd,
  });

  factory ApproveOtherRequestListingModel.fromJson(Map<String, dynamic> json) {
    return ApproveOtherRequestListingModel(
      date: json['dLsrdtf'].toString(),
      name: json['empName'].toString(),
      requestName: json['lsnote'].toString(),
      primaryKey: json['iLsslno'].toString(),
      rteant: json['rteant'].toString(),
      rqtmcd: json['rqemcd'],
    );
  }
}

class ApproveOtherRequestListResponse {
  final List<ApproveOtherRequestListingModel> submitted;
  final List<ApproveOtherRequestListingModel> approved;
  final List<ApproveOtherRequestListingModel> rejected;

  ApproveOtherRequestListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory ApproveOtherRequestListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return ApproveOtherRequestListResponse(
      submitted:
          (data['subLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveOtherRequestListingModel.fromJson(e))
              .toList(),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveOtherRequestListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => ApproveOtherRequestListingModel.fromJson(e))
              .toList(),
    );
  }
}

class ApproveOtherRequestFirstListingModel {
  String? menuName, requestId;
  String? menuId, count;

  ApproveOtherRequestFirstListingModel({
    this.menuName,
    this.menuId,
    this.requestId,
    this.count,
  });

  factory ApproveOtherRequestFirstListingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ApproveOtherRequestFirstListingModel(
      menuName: json['lsnote'].toString(),
      menuId: json['iAprlid'].toString(),
      requestId: json['lrtpac'].toString(),
      count: (json['oldCount'] ?? '') == '' ? '0' : json['oldCount'].toString(),
    );
  }
}
