import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/auth/controller/auth_controller.dart';
import 'package:zeta_ess/features/self_service/expense_claim/controller/expenseClaim_controller.dart';
import 'package:zeta_ess/features/self_service/expense_claim_form/models/claim_list_response.dart';
import 'package:zeta_ess/features/self_service/expense_claim_form/models/currency_model.dart';
import 'package:zeta_ess/features/self_service/expense_claim_form/models/save_claim_model.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../providers/api_providers.dart';
import '../repository/claim_repository.dart';

final claimControllerProvider = NotifierProvider<ClaimController, bool>(
  () => ClaimController(),
);

class ClaimController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  saveClaim({
    required BuildContext context,
    required SaveClaimModel saveClaimModel,
  }) {
    ref
        .read(claimRepositoryProvider)
        .saveExpClaimForm(
          userContext: ref.watch(userContextProvider),
          saveClaimModel: saveClaimModel,
        )
        .then((res) {
          res.fold(
            (l) => showSnackBar(
              context: context,
              content: 'Error while saving claim',
            ),
            (response) {
              showCustomAlertBox(context, title: response);
              print(response);
              print("response===");
              Navigator.pop(context);
              ref.invalidate(claimListProvider);
            },
          );
        });
  }

  Future<void> deleteClaim({
    required BuildContext context,
    required int claimId,
  }) async {
    state = true;

    final res = await ref
        .read(claimRepositoryProvider)
        .deleteExpClaimForm(
          userContext: ref.watch(userContextProvider),
          id: claimId,
        );
    state = false;

    return res.fold(
      (l) => showSnackBar(context: context, content: 'Error while deleting'),
      (response) => showSnackBar(context: context, content: response),
    );
  }
}

class ClaimListNotifier extends AutoDisposeAsyncNotifier<ClaimListResponse> {
  @override
  Future<ClaimListResponse> build() async {
    final repo = ref.read(claimRepositoryProvider);
    final userContext = ref.read(userContextProvider);
    final result = await repo.getExpenseClaimList(userContext: userContext);
    return result.fold((l) => throw l.errMsg, (r) => r);
  }
}

class CurrencyListNotifier
    extends AutoDisposeAsyncNotifier<List<CurrencyModel>> {
  @override
  Future<List<CurrencyModel>> build() async {
    final repo = ref.read(claimRepositoryProvider);
    final userContext = ref.read(userContextProvider);
    final result = await repo.bindCurrency(userContext: userContext);
    return result.fold((l) => throw l.errMsg, (r) => r);
  }
}
