import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../controller/loan_notifiers.dart';
import '../models/loan_details_model.dart';
import '../models/loan_list_model.dart';
import '../models/loan_type_model.dart';
import '../repository/loan_repository.dart';

final loanListProvider =
    AsyncNotifierProvider.autoDispose<LoanListNotifier, LoanListResponse>(
      LoanListNotifier.new,
    );

final loanDetailsProvider = FutureProvider.autoDispose
    .family<LoanDetailModel, String>((ref, loanId) async {
      final repo = ref.read(loanRepositoryProvider);
      final userContext = ref.watch(userContextProvider);

      final res = await repo.getLoanDetails(
        userContext: userContext,
        loanId: loanId,
      );

      return res.fold(
        (failure) => throw Exception(failure.errMsg),
        (data) => data,
      );
    });

final loanTypeListProvider = FutureProvider.autoDispose<List<LoanTypeModel>>((
  ref,
) async {
  final repo = ref.read(loanRepositoryProvider);
  final userContext = ref.watch(userContextProvider);

  final result = await repo.getLoanTypes(userContext: userContext);

  return result.fold(
    (failure) => throw Exception(failure.errMsg),
    (data) => data,
  );
});
