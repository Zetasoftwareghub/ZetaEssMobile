import 'package:get/get.dart';

class UserModel {
  final String esCode,
      empName,
      emCode,
      eminid,
      jwtToken,
      userBaseUrl,
      baseDirectory,
      password,
      userName;
  final String? alternateID;

  UserModel({
    required this.esCode,
    required this.password,
    required this.empName,
    required this.emCode,
    required this.eminid,
    required this.jwtToken,
    required this.baseDirectory,
    required this.userBaseUrl,
    required this.userName,
    this.alternateID,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      esCode: json['escode'].toString(),
      password: json['password'].toString(),
      empName: json['esname'].toString(),
      emCode: json['emcode'].toString(),
      eminid: json['eminid'].toString(),
      jwtToken: json['Token'].toString(),
      userBaseUrl: json['Baseurl'].toString(),
      baseDirectory: json['Basicdirectory'].toString(),
      userName: json['username'].toString(),
      alternateID:
          (json['emalid'] == null || json['emalid'] is Map)
              ? null
              : json['emalid'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'escode': esCode,
      'emalid': alternateID,
      'esname': empName,
      'emcode': emCode,
      'eminid': eminid,
      'Token': jwtToken,
      'Baseurl': userBaseUrl,
      'Basicdirectory': baseDirectory,
      'username': userName,
    };
  }

  /// ✅ copyWith for immutability
  UserModel copyWith({
    String? password,
    String? userName,
    String? esCode,
    String? empName,
    String? emCode,
    String? eminid,
    String? jwtToken,
    String? userBaseUrl,
    String? baseDirectory,
    String? alternateID,
  }) {
    return UserModel(
      esCode: esCode ?? this.esCode,
      password: password ?? this.password,
      empName: empName ?? this.empName,
      emCode: emCode ?? this.emCode,
      eminid: eminid ?? this.eminid,
      jwtToken: jwtToken ?? this.jwtToken,
      baseDirectory: baseDirectory ?? this.baseDirectory,
      userBaseUrl: userBaseUrl ?? this.userBaseUrl,
      userName: userName ?? this.userName,
      alternateID: alternateID ?? this.alternateID,
    );
  }
}
