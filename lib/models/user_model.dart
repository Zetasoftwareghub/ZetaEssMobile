import 'package:get/get.dart';

class UserModel {
  final String esCode,
      empName,
      emCode,
      eminid,
      jwtToken,
      userBaseUrl,
      baseDirectory;
  final String? alternateID;

  UserModel({
    required this.esCode,
    required this.empName,
    required this.emCode,
    required this.eminid,
    required this.jwtToken,
    required this.baseDirectory,
    required this.userBaseUrl,
    this.alternateID,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      esCode: json['escode'].toString(),
      empName: json['esname'].toString(),
      emCode: json['emcode'].toString(),
      eminid: json['eminid'].toString(),
      jwtToken: json['Token'].toString(),
      userBaseUrl: json['Baseurl'].toString(),
      baseDirectory: json['Basicdirectory'].toString(),
      alternateID:
          (json['emalid'] == null || json['emalid'] is Map)
              ? null
              : json['emalid'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'escode': esCode,
      'emalid': alternateID,
      'esname': empName,
      'emcode': emCode,
      'eminid': eminid,
      'Token': jwtToken,
      'Baseurl': userBaseUrl,
      'Basicdirectory': baseDirectory,
    };
  }
}
