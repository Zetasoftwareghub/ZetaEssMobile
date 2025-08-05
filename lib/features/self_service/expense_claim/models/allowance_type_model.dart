class AllowanceTypeModel {
  String? allowanceType;
  String? allowanceValue;

  AllowanceTypeModel({this.allowanceType, this.allowanceValue});

  factory AllowanceTypeModel.fromJson(Map<String, dynamic> json) {
    return AllowanceTypeModel(
      allowanceType: json['antitle'].toString(),
      allowanceValue: json['anmesg'],
    );
  }
}
