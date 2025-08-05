class LeaveBalanceModel {
  final String leaveName;
  final List<BalanceTypeModel> balTypeLst;

  LeaveBalanceModel({required this.leaveName, required this.balTypeLst});

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      leaveName: json['leaveName'] ?? '',
      balTypeLst:
          (json['balTypeLst'] as List)
              .map((e) => BalanceTypeModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaveName': leaveName,
      'balTypeLst': balTypeLst.map((e) => e.toJson()).toList(),
    };
  }
}

class BalanceTypeModel {
  final String balType;
  final String balTypeVal;

  BalanceTypeModel({required this.balType, required this.balTypeVal});

  factory BalanceTypeModel.fromJson(Map<String, dynamic> json) {
    return BalanceTypeModel(
      balType: json['balType'] ?? '',
      balTypeVal: json['balTypeVal'] ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {'balType': balType, 'balTypeVal': balTypeVal};
  }
}
