import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/features/self_service/change_request/models/address_model.dart';
import 'package:zeta_ess/features/self_service/change_request/models/change_request_model.dart';
import 'package:zeta_ess/features/self_service/change_request/models/change_request_types.dart';
import 'package:zeta_ess/features/self_service/change_request/models/country_details_model.dart';
import 'package:zeta_ess/features/self_service/change_request/repository/address_repository.dart';
import 'package:zeta_ess/features/self_service/change_request/repository/bank_repository.dart';
import 'package:zeta_ess/features/self_service/change_request/repository/change_request_repository.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../controller/notifiers.dart';
import '../models/bank_model.dart';
import '../models/change_request_list_response.dart';
import '../models/passport_model.dart';

final maritalStatusProvider = FutureProvider.family
    .autoDispose<String?, String?>((ref, empCode) async {
      final repository = ref.read(changeRequestRepositoryProvider);
      final userContext = ref.read(userContextProvider);
      // call the api
      final result = await repository.getMaritalStatus(
        userContext: userContext,
        empCode: empCode,
      );
      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (data) => data,
      );
    });

final countryListProvider =
    FutureProvider.autoDispose<List<CountryDetailsModel>>((ref) async {
      final userContext = ref.watch(userContextProvider);

      final result = await ref
          .watch(changeRequestRepositoryProvider)
          .getCountryDetails(userContext: userContext);

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (data) => data,
      );
    });

final banksListProvider = FutureProvider.autoDispose<List<BankModel>>((
  ref,
) async {
  final userContext = ref.watch(userContextProvider);

  final result = await ref
      .watch(bankRepositoryProvider)
      .getBankList(userContext: userContext);

  return result.fold(
    (failure) => throw Exception(failure.errMsg),
    (data) => data,
  );
});

final banksDetailsProvider = FutureProvider.family
    .autoDispose<BankDetailsModel, String?>((ref, employeeCode) async {
      final userContext = ref.watch(userContextProvider);

      final result = await ref
          .watch(bankRepositoryProvider)
          .getBankDetails(userContext: userContext, employeeCode: employeeCode);

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (data) => data,
      );
    });

final changeRequestDetailsFetchProvider = FutureProvider.family
    .autoDispose<ChangeRequestModel, int>((ref, reqId) async {
      final userContext = ref.watch(userContextProvider);
      final result = await ref
          .watch(changeRequestRepositoryProvider)
          .getChangeRequestDetails(userContext: userContext, reqId: reqId);

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (data) => data,
      );
    });

final addressContactDetailsProvider = FutureProvider.family
    .autoDispose<AddressContactModel, String?>((ref, employeeCode) async {
      final userContext = ref.watch(userContextProvider);

      final result = await ref
          .watch(addressRepositoryProvider)
          .getAddressContactDetails(
            userContext: userContext,
            employeeCode: employeeCode,
          );

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (data) => data,
      );
    });

final getRequestTypesListProvider =
    FutureProvider.autoDispose<List<ChangeRequestTypeModel>>((ref) async {
      final userContext = ref.watch(userContextProvider);

      final result = await ref
          .watch(changeRequestRepositoryProvider)
          .getRequestTypesList(userContext: userContext);

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (data) => data,
      );
    });

final changeRequestNotifierProvider = AutoDisposeAsyncNotifierProvider<
  ChangeRequestNotifier,
  ChangeRequestListResponseModel
>(ChangeRequestNotifier.new);

final passportDetailsNotifierProvider = AutoDisposeAsyncNotifierProviderFamily<
  PassportDetailsNotifier,
  PassportDetails,
  String?
>(PassportDetailsNotifier.new);
