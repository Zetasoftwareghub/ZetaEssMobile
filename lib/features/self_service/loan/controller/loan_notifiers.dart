import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/features/self_service/loan/models/loan_list_model.dart';
import 'package:zeta_ess/features/self_service/loan/repository/loan_repository.dart';

class LoanListNotifier extends AutoDisposeAsyncNotifier<LoanListResponse> {
  @override
  FutureOr<LoanListResponse> build() async {
    final repo = ref.read(loanRepositoryProvider);
    final userContext = ref.watch(userContextProvider);

    final res = await repo.getLoanList(userContext: userContext);

    return res.fold(
      (failure) => throw Exception(failure.errMsg),
      (data) => data,
    );
  }
}
