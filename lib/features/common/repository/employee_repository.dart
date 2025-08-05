import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/utils/date_utils.dart';
import 'package:zeta_ess/models/employeeMenu_model.dart';

import '../../../../core/api_constants/common_apis/common_apis.dart';
import '../../../../core/api_constants/common_apis/employee_api.dart';
import '../../../core/api_constants/dio_headers.dart';
import '../models/employee_profile.dart';
import '../models/leaveBalance_model.dart';
import '../models/mainMenus_model.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository();
});

class EmployeeRepository {
  final dio = Dio();

  FutureEither<EmployeeProfile> getEmployeeProfileDetails({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + EmployeeApi.employeeProfileDetails,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        final empData = data.first[0] as Map<String, dynamic>;
        final salaryList = data[3] as List<dynamic>;
        final allowanceList = data[4] as List<dynamic>;
        final deductionList = data[5] as List<dynamic>;

        return EmployeeProfile.fromJson(
          empData,
          salaryList,
          allowanceList,
          deductionList,
        );
      } else {
        throw Exception('Failed to load employee profile');
      }
    });
  }

  FutureEither<MainMenuModel> getMainMenuAgainstEmployee({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + EmployeeApi.getMainMenuAgainstEmployee,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return MainMenuModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load main menu');
      }
    });
  }

  FutureEither<EmployeeMenuModel> getEmployeeSelfLineMenus({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + EmployeeApi.getEmployeeSelfLineMenus,
        data: {
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return EmployeeMenuModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load employee menus');
      }
    });
  }

  FutureEither<List<LeaveBalanceModel>> getLeaveBalance({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final baseUrl = userContext.baseUrl + CommonApis.getLeaveBalance;
      print(DateTime.now().toString());
      print("response.data");
      final payload = {
        'emcode': userContext.empCode,
        'suconn': userContext.companyConnection,
        'dtleave': DateTime.now().toString(),
        'escode': int.parse(userContext.esCode),
        'id': 0,
      };

      final response = await dio.post(
        baseUrl,
        data: {
          'emcode': userContext.empCode,
          'suconn': userContext.companyConnection,
          'dtleave': formatDate(DateTime.now()),
          'escode': int.parse(userContext.esCode),
          'id': 0,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      print(response.data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => LeaveBalanceModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load leave balance');
      }
    });
  }
}
