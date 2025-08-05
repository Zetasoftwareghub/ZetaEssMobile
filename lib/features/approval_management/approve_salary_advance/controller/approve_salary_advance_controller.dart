import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_salary_advance_listing_model.dart';
import '../repository/approve_salary_advance_repository.dart';

final approveSalaryAdvanceListProvider = AutoDisposeAsyncNotifierProvider<
  ApproveSalaryAdvanceListNotifier,
  ApproveSalaryAdvanceListResponse
>(ApproveSalaryAdvanceListNotifier.new);

class ApproveSalaryAdvanceListNotifier
    extends AutoDisposeAsyncNotifier<ApproveSalaryAdvanceListResponse> {
  @override
  Future<ApproveSalaryAdvanceListResponse> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveSalaryAdvanceRepositoryProvider);
    final result = await repo.getApproveSalaryAdvanceList(
      userContext: userContext,
    );
    return result.fold((failure) => throw failure, (data) => data);
  }
}
