import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/change_request_list_response.dart';
import '../models/passport_model.dart';
import '../repository/change_request_repository.dart';
import '../repository/passport_repository.dart';

class ChangeRequestNotifier
    extends AutoDisposeAsyncNotifier<ChangeRequestListResponseModel> {
  @override
  Future<ChangeRequestListResponseModel> build() async {
    final userContext = ref.watch(userContextProvider);
    final repository = ref.watch(changeRequestRepositoryProvider);

    final result = await repository.getChangeRequestListing(
      userContext: userContext,
    );

    return result.fold(
      (failure) => throw Exception(failure.toString()),
      (data) => data,
    );
  }
}

class PassportDetailsNotifier
    extends AutoDisposeFamilyAsyncNotifier<PassportDetails, String?> {
  @override
  Future<PassportDetails> build(String? employeeCode) async {
    final repo = ref.watch(passportRepositoryProvider);
    final userContext = ref.watch(userContextProvider);
    final result = await repo.getPassportDetails(
      userContext: userContext,
      employeeCode: employeeCode,
    );
    return result.fold((l) => throw Exception(l.errMsg), (r) => r);
  }

  void updateNewValue(PassportDetails updated) {
    state = AsyncData(updated);
  }
}
