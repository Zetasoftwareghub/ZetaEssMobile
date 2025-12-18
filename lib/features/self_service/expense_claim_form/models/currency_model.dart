/// crname : "Emirati Dirham"
/// crcode : "AED"

class CurrencyModel {
  CurrencyModel({String? currencyName, String? crcode}) {
    _currencyName = currencyName;
    _crcode = crcode;
  }

  CurrencyModel.fromJson(dynamic json) {
    _currencyName = json['crname'];
    _crcode = json['crcode'];
  }
  String? _currencyName;
  String? _crcode;
  CurrencyModel copyWith({String? crname, String? crcode}) => CurrencyModel(
    currencyName: crname ?? _currencyName,
    crcode: crcode ?? _crcode,
  );

  String? get currencyName => _currencyName;
  String? get crcode => _crcode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['crname'] = _currencyName;
    map['crcode'] = _crcode;
    return map;
  }
}
