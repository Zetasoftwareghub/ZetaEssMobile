class PassportDetails {
  final int serialNumber;
  final int employeeCode;
  final String passportNumber;
  final DateTime? issuedDate;
  final String placeOfIssue;
  final DateTime? expiryDate;
  final String issuedCountry;
  final String nationality;
  final String passportHolder;
  final String employer;

  PassportDetails({
    required this.serialNumber,
    required this.employeeCode,
    required this.passportNumber,
    required this.issuedDate,
    required this.placeOfIssue,
    required this.expiryDate,
    required this.issuedCountry,
    required this.nationality,
    required this.passportHolder,
    required this.employer,
  });

  factory PassportDetails.fromJson(Map<String, dynamic> json) {
    return PassportDetails(
      serialNumber: json['eoslno'] ?? 0,
      employeeCode: json['emcode'] ?? 0,
      passportNumber: json['eopano'] ?? '',
      issuedDate: DateTime.tryParse(json['eopadt'] ?? ''),
      placeOfIssue: json['eopapl'] ?? '',
      expiryDate: DateTime.tryParse(json['eopaed'] ?? ''),
      issuedCountry: json['cucode'] ?? '',
      nationality: json['cuntcd'] ?? '',
      passportHolder: json['eopahl'] ?? '',
      employer: json['eohcct'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eoslno': serialNumber,
      'emcode': employeeCode,
      'eopano': passportNumber,
      'eopadt': issuedDate.toString(),
      'eopapl': placeOfIssue,
      'eopaed': expiryDate.toString(),
      'cucode': issuedCountry,
      'cuntcd': nationality,
      'eopahl': passportHolder,
      'eohcct': employer,
    };
  }
}
