class NotificationModel {
  String? name;
  String? count;
  String? id;
  int? slNumber;

  NotificationModel({this.name, this.count, this.id, this.slNumber});

  factory NotificationModel.fromJsonApprovalApi(Map<String, dynamic> json) {
    return NotificationModel(
      name: json['CAPTION'].toString(),
      count: json['LCOUNT'].toString(),
      id: json['MICODE'].toString(),
    );
  }

  factory NotificationModel.fromJsonPendingApi(Map<String, dynamic> json) {
    return NotificationModel(
      name: json['caption'].toString(),
      count: json['pendcnt'].toString(),
      id: json['micode'].toString(),
    );
  }
}
