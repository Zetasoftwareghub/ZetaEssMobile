class ChangeRequestTypeModel {
  final String requestName;
  final String value;

  ChangeRequestTypeModel({required this.requestName, required this.value});

  factory ChangeRequestTypeModel.fromJson(Map<String, dynamic> json) {
    return ChangeRequestTypeModel(
      requestName: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }
}
