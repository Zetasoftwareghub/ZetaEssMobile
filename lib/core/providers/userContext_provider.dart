import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';

final userContextProvider = Provider<UserContext>((ref) {
  final baseUrl = ref.watch(baseUrlProvider) ?? '';
  final empCode = ref.watch(userDataProvider)?.emCode ?? '';
  final empEminid = ref.watch(userDataProvider)?.eminid ?? '';
  final esCode = ref.watch(userDataProvider)?.esCode ?? '';
  final empName = ref.watch(userDataProvider)?.empName ?? '';
  final companyConnection = ref.watch(userCompanyProvider)?.companyConnection;
  final companyCode =
      ref.watch(userCompanyProvider)?.companyCode.toString() ?? '';
  final jwtToken = ref.watch(userDataProvider)?.jwtToken;
  final userBaseUrl = ref.watch(userDataProvider)?.userBaseUrl;
  final baseDirectory = ref.watch(userDataProvider)?.baseDirectory;
  final alternateID = ref.watch(userDataProvider)?.alternateID;

  return UserContext(
    baseUrl: baseUrl,
    esCode: esCode,
    empName: empName,
    empCode: empCode,
    companyConnection: companyConnection,
    jwtToken: jwtToken,
    empEminid: empEminid,
    baseDirectory: baseDirectory,
    userBaseUrl: userBaseUrl,
    alternateID: alternateID,
    companyCode: companyCode,
  );
});

class UserContext {
  final String baseUrl;
  final String companyCode;
  final String esCode; //user id some apis !
  final String empCode;
  final String empName;
  final String empEminid;
  final String? companyConnection;
  final String? jwtToken;
  final String? baseDirectory, userBaseUrl, alternateID;

  UserContext({
    required this.baseUrl,
    required this.companyCode,
    required this.esCode,
    required this.empCode,
    required this.empEminid,
    required this.empName,
    required this.companyConnection,
    required this.jwtToken,
    required this.baseDirectory,
    required this.userBaseUrl,
    required this.alternateID,
  });

  Map<String, dynamic> toJson() {
    return {
      'suconn': companyConnection,
      'sucode': companyCode,
      'emcode': empCode,
      'userid': esCode,
      'empName': empName,
      'empEminid': empEminid,
      'url': baseUrl,
      'jwtToken': jwtToken,
      'micode': '0',
      "activateurl": baseUrl,
      'baseUrl': userBaseUrl,
      'baseDirectory': baseDirectory,
      'alternateID': alternateID,
      'companyCode': companyCode,
    };
  }
}
