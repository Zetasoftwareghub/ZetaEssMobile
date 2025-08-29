class CountryDetailsModel {
  final String countryCode;
  final String countryName;

  CountryDetailsModel({required this.countryCode, required this.countryName});

  factory CountryDetailsModel.fromJson(Map<String, dynamic> json) {
    return CountryDetailsModel(
      countryCode: json['cucode'] ?? '',
      countryName: json['countryname'] ?? '',
    );
  }
}
