import 'dart:convert';

import '../services/secure_stroage_service.dart';

class CompanyModel {
  final int companyCode;
  final String companyName;
  final String companyConnection;

  CompanyModel({
    required this.companyCode,
    required this.companyName,
    required this.companyConnection,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyCode: json['sucode'],
      companyName: json['suname'],
      companyConnection: json['suconn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucode': companyCode,
      'suname': companyName,
      'suconn': companyConnection,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CompanyModel && other.companyCode == companyCode;
  }

  @override
  int get hashCode => companyCode.hashCode;
}

// TODO change code from here Save model to secure storage
Future<void> saveCompanyLocal(CompanyModel model) async {
  final jsonString = jsonEncode(model.toJson());
  await SecureStorageService.write(key: 'companyModel', value: jsonString);
}

// Retrieve model from secure storage
Future<CompanyModel?> getCompanyLocal() async {
  final jsonString = await SecureStorageService.read(key: 'companyModel');
  if (jsonString != null) {
    final jsonMap = jsonDecode(jsonString);
    return CompanyModel.fromJson(jsonMap);
  }
  return null;
}
