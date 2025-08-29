class BankModel {
  final int bankCode;
  final String bankName;
  final String branchName;
  final String branchCode;
  final String defaultFlag;
  final String status;
  final String bankDisplayName;

  BankModel({
    required this.bankCode,
    required this.bankName,
    required this.branchName,
    required this.branchCode,
    required this.defaultFlag,
    required this.status,
    required this.bankDisplayName,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      bankCode: json['bacode'] ?? 0,
      bankName: json['baname'] ?? '',
      branchName: json['babrnm'] ?? '',
      branchCode: json['barocd'] ?? '',
      defaultFlag: json['badflg'] ?? '',
      status: json['bastat'] ?? '',
      bankDisplayName: json['bank'] ?? '',
    );
  }
}

class BankDetailsModel {
  final int bankDetailsId; // bcslno
  final int employeeCode; // emcode
  final int bankCode; // bacode
  final String currencyCode; // crcode
  final String accountNumber; // bcacno
  final int branchSerialNumber; // cbslno
  final double percentage; // bcperc
  final String status; // bcstat
  final String accountName; // bcacnm
  final String countryCode; // cucode

  BankDetailsModel({
    required this.bankDetailsId,
    required this.employeeCode,
    required this.bankCode,
    required this.currencyCode,
    required this.accountNumber,
    required this.branchSerialNumber,
    required this.percentage,
    required this.status,
    required this.accountName,
    required this.countryCode,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsModel(
      bankDetailsId: json['bcslno'] ?? 0,
      employeeCode: json['emcode'] ?? 0,
      bankCode: json['bacode'] ?? 0,
      currencyCode: json['crcode']?.toString().trim() ?? '',
      accountNumber: json['bcacno'] ?? '',
      branchSerialNumber: json['cbslno'] ?? 0,
      percentage:
          (json['bcperc'] is int)
              ? (json['bcperc'] as int).toDouble()
              : (json['bcperc'] ?? 0).toDouble(),
      status: json['bcstat'] ?? '',
      accountName: json['bcacnm'] ?? '',
      countryCode: json['cucode'] ?? '',
    );
  }
}
