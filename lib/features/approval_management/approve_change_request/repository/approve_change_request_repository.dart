import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/approval_manager_apis/approve_apis.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';

import '../../../../core/api_constants/dio_headers.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_change_req.dart';
import '../models/approve_listing_model.dart';

final approveChangeRequestRepositoryProvider =
    Provider<ApproveChangeRequestRepository>(
      (ref) => ApproveChangeRequestRepository(),
    );

class ApproveChangeRequestRepository {
  final dio = Dio();

  FutureEither<String?> approveRejectChangeRequest({
    required UserContext userContext,
    required ApproveChangeRequestModel approve,
  }) {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.approveRejectChangeRequest,
        data: approve.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to ApproveLieuDay request');
      }
    });
  }

  FutureEither<ApproveChangeRequestListResponseModel>
  getApproveChangeRequestListing({required UserContext userContext}) async {
    return handleApiCall(() async {
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveChangeRequestList,
        data: userContext.toJson(),
        options: dioHeader(token: userContext.jwtToken),
      );
      print(response.data['data']);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApproveChangeRequestListResponseModel.fromJson(
          response.data['data'],
        );
      } else {
        throw Exception('Failed to load approve change requests');
      }
    });
  }
}
