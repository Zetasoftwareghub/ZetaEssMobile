import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';

import '../../../../core/api_constants/approval_manager_apis/approve_apis.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_lieu_day_listing_model.dart';

final approveLieuDayRepositoryProvider = Provider<ApproveLieuDayRepository>((
  ref,
) {
  return ApproveLieuDayRepository();
});

class ApproveLieuDayRepository {
  final dio = Dio();

  FutureEither<ApproveLieuDayListResponse> getApproveLieuDayList({
    required UserContext userContext,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveLieuDayList,
        data: {
          'userid': userContext.esCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApproveLieuDayListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load ApproveLieuDay list');
      }
    });
  }

  FutureEither<String?> approveRejectLieu({
    required UserContext userContext,
    required String note,
    required String requestId,
    required String approveRejectFlag,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.approveRejectLieu,
        data: {
          "strapprflg": approveRejectFlag,
          "rqldcode": requestId,
          "strEmcode": userContext.empCode,
          "username": userContext.empName,
          "strNote": note,
          "suconn": userContext.companyConnection,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to ApproveLieuDay request');
      }
    });
  }
}
