import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';
import '../models/approve_loan_listing_model.dart';
import '../models/approve_loan_model.dart';
import '../repository/approve_loan_repository.dart';

final approveLoanControllerProvider =
    NotifierProvider<ApproveLoanController, bool>(
      () => ApproveLoanController(),
    );

class ApproveLoanController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> approveRejectLoan({
    required ApproveLoanModel approveLoanModel,
    required BuildContext context,
  }) async {
    state = true;

    final repo = ref.read(approveLoanRepositoryProvider);
    final userContext = ref.read(userContextProvider);
    final result = await repo.approveRejectLoan(
      userContext: userContext,
      approveLoanModel: approveLoanModel,
    );
    state = false;

    return result.fold(
      (failure) => showSnackBar(context: context, content: failure.errMsg),
      (res) {
        ref.invalidate(approveLoanListProvider);
        showSnackBar(
          context: context,
          content: res ?? 'Request processed successfully',
        );
        if (res == 'Loan approved successfully' ||
            res == 'Loan rejected successfully') {
          Navigator.pop(context);
        }
      },
    );
  }
}

final approveLoanListProvider = AutoDisposeAsyncNotifierProvider<
  ApproveLoanListNotifier,
  ApproveLoanListResponse
>(ApproveLoanListNotifier.new);

class ApproveLoanListNotifier
    extends AutoDisposeAsyncNotifier<ApproveLoanListResponse> {
  @override
  Future<ApproveLoanListResponse> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveLoanRepositoryProvider);
    final result = await repo.getApproveLoanList(userContext: userContext);
    return result.fold((failure) {
      throw failure;
    }, (data) => data);
  }
}
