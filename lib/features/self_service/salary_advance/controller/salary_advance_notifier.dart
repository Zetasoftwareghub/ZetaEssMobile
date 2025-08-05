import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/salaryAdvance_listing_model.dart';
import '../models/salary_advance_details.dart';
import '../repository/salary_advance_repository.dart';

class SalaryAdvanceListNotifier
    extends AutoDisposeAsyncNotifier<SalaryAdvanceListResponse> {
  @override
  Future<SalaryAdvanceListResponse> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(salaryAdvanceRepositoryProvider);

    final result = await repo.getSalaryAdvanceList(userContext: userContext);
    return result.fold((failure) => throw failure, (data) => data);
  }
}

class SalaryAdvanceDetailsNotifier
    extends AutoDisposeFamilyAsyncNotifier<SalaryAdvanceDetailsModel, String?> {
  @override
  Future<SalaryAdvanceDetailsModel> build(String? salaryAdvanceId) async {
    final repo = ref.read(salaryAdvanceRepositoryProvider);
    final user = ref.read(userContextProvider);

    final result = await repo.getSalaryAdvanceDetails(
      userContext: user,
      salaryAdvanceId: salaryAdvanceId ?? '0',
    );

    return result.fold(
      (failure) => throw Exception(failure.errMsg),
      (data) => data,
    );
  }
}
