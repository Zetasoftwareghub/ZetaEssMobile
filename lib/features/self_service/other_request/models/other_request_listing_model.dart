import '../../../../models/listRights_model.dart';

class OtherRequestListingModel {
  String? date;
  String? name;
  String? requestName;
  String? primaryKey;
  String? comment;

  OtherRequestListingModel({
    this.date,
    this.name,
    this.requestName,
    this.primaryKey,
    this.comment,
  });

  factory OtherRequestListingModel.fromJson(Map<String, dynamic> json) {
    return OtherRequestListingModel(
      date: json['rtEnDt']?.toString(),
      name: json['emName']?.toString(),
      requestName: json['rqName']?.toString(),
      primaryKey: json['rtEnCd']?.toString() ?? "0",
      comment: json['rteant']?.toString() ?? "",
    );
  }
}

class OtherRequestListResponse {
  final SubmittedOtherRequestResponse submitted;
  final List<OtherRequestListingModel> approved;
  final List<OtherRequestListingModel> rejected;

  OtherRequestListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory OtherRequestListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return OtherRequestListResponse(
      submitted: SubmittedOtherRequestResponse.fromJson(json),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => OtherRequestListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => OtherRequestListingModel.fromJson(e))
              .toList(),
    );
  }
}

class SubmittedOtherRequestResponse {
  final List<OtherRequestListingModel> requestList;
  final ListRightsModel listRights;

  SubmittedOtherRequestResponse({
    required this.requestList,
    required this.listRights,
  });

  factory SubmittedOtherRequestResponse.fromJson(Map<String, dynamic> json) {
    final subList = (json['data']['subLst'] ?? []) as List<dynamic>;

    return SubmittedOtherRequestResponse(
      requestList:
          subList.map((e) => OtherRequestListingModel.fromJson(e)).toList(),
      listRights: ListRightsModel.fromJson(json['data']['rights'] ?? {}),
    );
  }
}

class OtherRequestFirstListingModel {
  String? menuName;
  String? menuId;
  String? lRTPAC;
  int? count;

  OtherRequestFirstListingModel({
    this.menuName,
    this.menuId,
    this.lRTPAC,
    this.count,
  });

  factory OtherRequestFirstListingModel.fromJson(Map<String, dynamic> json) {
    return OtherRequestFirstListingModel(
      menuName: json['lsnote'].toString(),
      menuId: json['iAprlid'].toString(),
      lRTPAC: json['lrtpac'].toString(),
      count: int.parse(
        (json['oldCount'] ?? '') == '' ? '0' : json['oldCount'].toString(),
      ),
    );
  }
}
