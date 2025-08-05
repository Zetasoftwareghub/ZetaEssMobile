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

  FutureEither<List<PunchModel>> getPunchDetails({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + CommonApis.getPunchDetails,
        data: {
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
      final response = await dio.post(
        userContext.baseUrl + CommonApis.savePunch,
        data: {
          'suconn': userContext.companyConnection,
          'cocode': 0,
          'emcode': userContext.empCode,
          'latLong': "${loc.position.latitude},${loc.position.longitude}",
          // 'latLong': "11111,11111", //TODO make this above code !
          "location": loc.placeName,
          'geotag': ipAddress,
          'locationTime': locationTime,
        },
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
