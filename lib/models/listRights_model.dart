class ListRightsModel {
  bool? canCreate;
  bool? canEdit;
  bool? canDelete;

  ListRightsModel({this.canCreate, this.canEdit, this.canDelete});

  ListRightsModel.fromJson(Map<String, dynamic> json) {
    canCreate = json['isPageAdd'] ?? false;
    canEdit = json['isPageEdit'] ?? false;
    canDelete = json['isPageDelete'] ?? false;
  }
}
