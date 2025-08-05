import '../../../../models/listRights_model.dart';

class LieuDayListingModel {
  String? ludate;
  String? lulvtp;
  String? rqldcode;
  String? emname;
  String? emcode;
  String? lurmrk;
  String? apstat;
  String? lmname;
  String? apnotes;
  String? fromTime;
  String? toTime;
  String? luatt;
  String? rqempname;

  LieuDayListingModel({
    this.ludate,
    this.lulvtp,
    this.rqldcode,
    this.emname,
    this.emcode,
    this.lurmrk,
    this.apstat,
    this.lmname,
    this.apnotes,
    this.fromTime,
    this.toTime,
    this.luatt,
    this.rqempname,
  });

  factory LieuDayListingModel.fromJson(Map<String, dynamic> json) {
    return LieuDayListingModel(
      ludate: json["ludate"]?.toString(),
      lulvtp: json["lulvtp"]?.toString(),
      rqldcode: json["rqldcode"]?.toString(),
      emname: json["emname"]?.toString(),
      emcode: json["emcode"]?.toString(),
      lurmrk: json["lurmrk"]?.toString(),
      apstat: json["apstat"]?.toString(),
      lmname: json["lmname"]?.toString(),
      apnotes: json["apnotes"]?.toString(),
      fromTime: json["fromTime"]?.toString(),
      toTime: json["toTime"]?.toString(),
      luatt: json["luatt"]?.toString(),
      rqempname: json["rqempname"]?.toString(),
    );
  }
}

class SubmittedLieuDayResponse {
  final List<LieuDayListingModel> lieuDayList;
  final ListRightsModel listRights;

  SubmittedLieuDayResponse({
    required this.lieuDayList,
    required this.listRights,
  });

  factory SubmittedLieuDayResponse.fromJson(Map<String, dynamic> json) {
    final subList = (json['data']['subLst'] ?? []) as List<dynamic>;

    return SubmittedLieuDayResponse(
      lieuDayList: subList.map((e) => LieuDayListingModel.fromJson(e)).toList(),
      listRights: ListRightsModel.fromJson(json['data']['rights'] ?? {}),
    );
  }
}

class LieuDayListResponse {
  final SubmittedLieuDayResponse submitted;
  final List<LieuDayListingModel> approved;
  final List<LieuDayListingModel> rejected;

  LieuDayListResponse({
    required this.submitted,
    required this.approved,
    required this.rejected,
  });

  factory LieuDayListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return LieuDayListResponse(
      submitted: SubmittedLieuDayResponse.fromJson(json),
      approved:
          (data['appLst'] as List<dynamic>? ?? [])
              .map((e) => LieuDayListingModel.fromJson(e))
              .toList(),
      rejected:
          (data['rejLst'] as List<dynamic>? ?? [])
              .map((e) => LieuDayListingModel.fromJson(e))
              .toList(),
    );
  }
}
