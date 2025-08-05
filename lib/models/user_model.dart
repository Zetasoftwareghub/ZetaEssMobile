class UserModel {
  final String esCode,
      empName,
      emCode,
      eminid,
      jwtToken,
      userBaseUrl,
      baseDirectory;

  UserModel({
    required this.esCode,
    required this.empName,
    required this.emCode,
    required this.eminid,
    required this.jwtToken,
    required this.baseDirectory,
    required this.userBaseUrl,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'escode': esCode,
      'esname': empName,
      'emcode': emCode,
      'eminid': eminid,
      'Token': jwtToken,
      'Baseurl': userBaseUrl,
      'Basicdirectory': baseDirectory,
    };
  }
}
