class ApproveOtherRequestListingModel {
  String? menuName;
  String? menuId;
  String? rfcode;
  String? count;

  ApproveOtherRequestListingModel({
    this.menuName,
    this.menuId,
    this.rfcode,
    this.count,
  });

  factory ApproveOtherRequestListingModel.fromJson(Map<String, dynamic> json) {
    return ApproveOtherRequestListingModel(
      menuName: json['lsnote'].toString(),
      menuId: json['iAprlid'].toString(),
      rfcode: json['lrtpac'].toString(),
      count: (json['oldCount'] ?? '') == '' ? '0' : json['OldCount'].toString(),
    );
  }
}

//
// class ApproveOtherRequestListResponse {
//   final List<ApproveOtherRequestListingModel> submitted;
//   final List<ApproveOtherRequestListingModel> approved;
//   final List<ApproveOtherRequestListingModel> rejected;
//
//   ApproveOtherRequestListResponse({
//     required this.submitted,
//     required this.approved,
//     required this.rejected,
//   });
//
//   factory ApproveOtherRequestListResponse.fromJson(Map<String, dynamic> json) {
//     final data = json['data'] ?? {};
//
//     return ApproveOtherRequestListResponse(
//       submitted:
//           (data['subLst'] as List<dynamic>? ?? [])
//               .map((e) => ApproveOtherRequestListingModel.fromJson(e))
//               .toList(),
//       approved:
//           (data['appLst'] as List<dynamic>? ?? [])
//               .map((e) => ApproveOtherRequestListingModel.fromJson(e))
//               .toList(),
//       rejected:
//           (data['rejLst'] as List<dynamic>? ?? [])
//               .map((e) => ApproveOtherRequestListingModel.fromJson(e))
//               .toList(),
//     );
//   }
// }
