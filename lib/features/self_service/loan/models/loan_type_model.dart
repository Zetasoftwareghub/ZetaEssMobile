class LoanTypeModel {
  final String typeCode;
  final String typeName;
  final String loremk;
  final int? reapplicationInterval;
  final String lostat;

  LoanTypeModel({
    required this.typeCode,
    required this.typeName,
    required this.loremk,
    this.reapplicationInterval,
    required this.lostat,
  });

  factory LoanTypeModel.fromJson(Map<String, dynamic> json) {
    return LoanTypeModel(
      typeCode: json['locode'].toString(),
      typeName: json['loname'] as String,
      loremk: json['loremk'] as String,
      reapplicationInterval:
          json['reapplicationInterval'] != null
              ? json['reapplicationInterval'] as int
              : null,
      lostat: json['lostat'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locode': typeCode,
      'loname': typeName,
      'loremk': loremk,
      'reapplicationInterval': reapplicationInterval,
      'lostat': lostat,
    };
  }
}
