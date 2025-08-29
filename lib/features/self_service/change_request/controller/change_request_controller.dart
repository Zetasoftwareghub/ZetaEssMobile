import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/change_request/repository/change_request_repository.dart';

import '../models/change_request_model.dart';
import '../providers/change_request_providers.dart';

final changeRequestControllerProvider =
    NotifierProvider<ChangeRequestController, bool>(() {
      return ChangeRequestController();
    });

class ChangeRequestController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> submitChangeRequest({
    required BuildContext context,
    required ChangeRequestModel saveModel,
  }) async {
    state = true;
    final res = await ref
        .read(changeRequestRepositoryProvider)
        .submitChangeRequest(
          userContext: ref.watch(userContextProvider),
          saveModel: saveModel,
        );
    state = false;

    res.fold((l) => showSnackBar(context: context, content: l.errMsg), (r) {
      ref.invalidate(changeRequestNotifierProvider);

      Navigator.pop(context);
      showSnackBar(context: context, content: r);
    });
  }

  Future<void> deleteChangeRequest({
    required BuildContext context,
    required int changeRequestId,
  }) async {
    state = true;
    final res = await ref
        .read(changeRequestRepositoryProvider)
        .deleteChangeRequest(
          userContext: ref.watch(userContextProvider),
          reqId: changeRequestId,
        );
    state = false;

    res.fold((l) => showSnackBar(context: context, content: l.errMsg), (r) {
      ref.invalidate(changeRequestNotifierProvider);
      showSnackBar(context: context, content: r);
    });
  }
}
