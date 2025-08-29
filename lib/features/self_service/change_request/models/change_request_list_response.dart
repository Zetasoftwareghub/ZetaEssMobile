import 'package:zeta_ess/models/listRights_model.dart';

class ChangeRequestListResponseModel {
  final SubmittedChangeRequestModel submittedModel;
  final List<ChangeRequestListModel> approved;
  final List<ChangeRequestListModel> rejected;

  ChangeRequestListResponseModel({
    required this.submittedModel,
    required this.approved,
    required this.rejected,
  });

  factory ChangeRequestListResponseModel.fromJson(json) {
    final List? data = json['data'];

    List<ChangeRequestListModel> parse(int index) {
      if (data == null || data.length <= index || data[index] is! List) {
        return [];
      }
      return (data[index] as List)
          .whereType<Map<String, dynamic>>()
          .map((req) => ChangeRequestListModel.fromJson(req))
          .toList();
    }

    return ChangeRequestListResponseModel(
      submittedModel: SubmittedChangeRequestModel.fromJson(json),
      approved: parse(1),
      rejected: parse(2),
    );
  }
}

class SubmittedChangeRequestModel {
  final List<ChangeRequestListModel> submitted;
  final ListRightsModel rights;

  SubmittedChangeRequestModel({required this.submitted, required this.rights});

  factory SubmittedChangeRequestModel.fromJson(Map<String, dynamic> json) {
    // Parse submitted data (data[0])
    List<ChangeRequestListModel> submittedList = [];
    final data = json['data'];
    if (data is List && data.isNotEmpty && data[0] is List) {
      submittedList =
          (data[0] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ChangeRequestListModel.fromJson(e))
              .toList();
    }

    // Parse rights
    final rightsJson = json['rights'] as Map<String, dynamic>? ?? {};
    final rights = ListRightsModel.fromJson(rightsJson);

    return SubmittedChangeRequestModel(
      submitted: submittedList,
      rights: rights,
    );
  }
}

class ChangeRequestListModel {
  final int chrqcd;
  final String? date;
  final int emcode;
  final String chrqtp;
  final String requestType;
  final int bacode;
  final String? bcacno;
  final String? bcacnm;
  final String chrqst;
  final String? chapby;
  final String? chapdt;
  final String? chapnt;
  final String emname;
  final String eminid;
  final String status;

  ChangeRequestListModel({
    required this.chrqcd,
    required this.date,
    required this.emcode,
    required this.chrqtp,
    required this.requestType,
    required this.bacode,
    this.bcacno,
    this.bcacnm,
    required this.chrqst,
    this.chapby,
    this.chapdt,
    this.chapnt,
    required this.emname,
    required this.eminid,
    required this.status,
  });

  factory ChangeRequestListModel.fromJson(Map<String, dynamic> json) {
    return ChangeRequestListModel(
      chrqcd: json['chrqcd'] ?? '',
      date: json['chrqdt'] ?? "",
      emcode: json['emcode'] ?? "",
      chrqtp: json['chrqtp'] ?? "",
      requestType: json['chrqtp_text'] ?? "",
      bacode: json['bacode'] ?? "",
      bcacno: json['bcacno'] ?? "",
      bcacnm: json['bcacnm'] ?? "",
      chrqst: json['chrqst'] ?? "",
      chapby: json['chapby'] ?? "",
      chapdt: json['chapdt'] ?? "",
      chapnt: json['chapnt'] ?? "",
      emname: json['emname'] ?? "",
      eminid: json['eminid'] ?? "",
      status: json['apstat'] ?? "",
    );
  }
}
