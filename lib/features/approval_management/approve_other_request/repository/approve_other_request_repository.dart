import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/dio_headers.dart';
import 'package:zeta_ess/core/error_handling/type_defs.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/api_constants/approval_manager_apis/approve_apis.dart';
import '../../../../core/api_constants/self_service_apis/other_request_apis.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_listing_model.dart';

final approveOtherRequestRepositoryProvider =
    Provider<ApproveOtherRequestRepository>((ref) {
      return ApproveOtherRequestRepository();
    });

class ApproveOtherRequestRepository {
  final dio = Dio();

  FutureEither<List<ApproveOtherRequestFirstListingModel>>
  getFirstApproveOtherRequestList({required UserContext userContext}) {
    return handleApiCall(() async {
      print('response');
      print(userContext.companyConnection);
      print(userContext.empCode);
      final response = await dio.post(
        userContext.baseUrl +
            OtherRequestApis.getApprovalOtherRequestFirstListing,
        data: {
          'sucode': userContext.companyCode,
          'suconn': userContext.companyConnection,
          'emcode': userContext.empCode,
        },
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'];
        //TODO ithinte response model vere annu bro
        print('response.data');
        printFullJson(dataList);
        return dataList
            .map((json) => ApproveOtherRequestFirstListingModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load lieu days');
      }
    });
  }
  //
  // FutureEither<OtherRequestListResponse> getOtherApproveRequestList({
  //   required UserContext userContext,
  //   required String? requestId,
  //   required String? micode,
  // }) async {
  //   return handleApiCall(() async {
  //     print(userContext.empCode);
  //     print(userContext.esCode);
  //     print(requestId);
  //     print(micode);
  //     print('micode');
  //     final response = await dio.post(
  //       userContext.baseUrl + OtherRequestApis.getOtherRequestList,
  //       data: {
  //         'sucode' : userContext.companyCode,'suconn': userContext.companyConnection,
  //         'emcode': userContext.empCode,
  //         'userid': userContext.esCode,
  //         'rfcode': requestId,
  //         'micode': micode,
  //       },
  //       options: dioHeader(token: userContext.jwtToken),
  //     );
  //     if (response.statusCode == 200 && response.data['success'] == true) {
  //       return OtherRequestListResponse.fromJson(response.data);
  //     } else {
  //       throw Exception('Failed to load lieu days');
  //     }
  //   });
  // }

  FutureEither<ApproveOtherRequestListResponse> getApproveOtherRequestList({
    required UserContext userContext,
    required String rfcode,
    required String micode,
  }) {
    return handleApiCall(() async {
      final data = {
        'userid': userContext.esCode,
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        'emcode': userContext.empCode,
        "username": userContext.empName,
        "rfcode": rfcode.toString(),
        "micode": micode.toString(),
      };
      print(data);
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.getApproveOtherRequestList,
        data: data,
        options: dioHeader(token: userContext.jwtToken),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApproveOtherRequestListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load ApproveOtherRequest list');
      }
    });
  }

  FutureEither<String?> approveRejectOtherRequest({
    required UserContext userContext,
    required String note,
    required String requestId,
    required String primaryKey,
    required String micode,
    required String requestName,
    required String approveRejectFlag,
  }) {
    return handleApiCall(() async {
      final data = {
        "employeename": userContext.empName,
        "primekey": primaryKey,
        "comment": note,
        "emcode": userContext.empCode,
        "micode": micode,
        'sucode': userContext.companyCode,
        'suconn': userContext.companyConnection,
        "flag": approveRejectFlag,
        "requestName": requestName,
        "baseDirectory": userContext.baseDirectory,
        "emp_nam": userContext.empName,
        "emp_mail": userContext.empEminid,
      };
      print(data);
      print('otherr requ');
      final response = await dio.post(
        userContext.baseUrl + ApproveApis.approveRejectOtherRequest,
        data: data,
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
