import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/api_constants/common_apis/common_apis.dart';
import '../../../../../core/api_constants/dio_headers.dart';
import '../../../../../core/error_handling/type_defs.dart';
import '../../../../../core/providers/userContext_provider.dart';
import '../../models/punch_model.dart';
import '../controller/liveLocation_controller.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

class HomeRepository {
  final dio = Dio();

  FutureEither<String> getShiftAgainstEmployee({
    required UserContext userContext,
    required String date,
  }) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + CommonApis.getEmployeeShift,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'ckdate': date,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] ?? 'No Data';
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  FutureEither<List<PunchModel>> getPunchDetails({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + CommonApis.getPunchDetails,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
          'userid': userContext.esCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['subLst'];
        return data.map((e) => PunchModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  FutureEither<String> savePunch({
    required UserContext userContext,
    required LiveLocation loc,
    required ipAddress,
    required String locationTime,
  }) async {
    return handleApiCall(() async {
      final data = {
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        'cocode': 0,
        'emcode': userContext.empCode,
        'latLong': "${loc.position.latitude},${loc.position.longitude}",
        "location": loc.placeName,
        'geotag': ipAddress,
        'locationTime': locationTime,
      };

      print(data);
      print('punch save');
      final response = await dio.post(
        userContext.baseUrl + CommonApis.savePunch,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final result = response.data['data'];
        if (result == '25') {
          throw Exception('Invalid alternative id');
        }

        return result.toString();
      } else {
        throw Exception('Failed to load punch status');
      }
    });
  }
}
