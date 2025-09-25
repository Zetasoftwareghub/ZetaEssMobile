import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/features/approval_management/approve_change_request/controller/notifier.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/utils.dart';
import '../models/approve_change_req.dart';
import '../repository/approve_change_request_repository.dart';

final approveChangeRequestControllerProvider =
    NotifierProvider<ApproveChangeRequestController, bool>(
      () => ApproveChangeRequestController(),
    );

class ApproveChangeRequestController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> approveRejectChangeRequest({
    required ApproveChangeRequestModel approveChangeRequestModel,
    required BuildContext context,
  }) async {
    state = true;

    final repo = ref.read(approveChangeRequestRepositoryProvider);
    final userContext = ref.read(userContextProvider);
    final result = await repo.approveRejectChangeRequest(
      userContext: userContext,
      approve: approveChangeRequestModel,
    );
    state = false;

    return result.fold(
      (failure) => showSnackBar(context: context, content: failure.errMsg),
      (res) {
        ref.invalidate(approveChangeRequestListProvider);

        if (res == 'Change request approved successfully' ||
            res == 'Change request rejected successfully') {
          Navigator.pop(context);
        }
        showSnackBar(
          context: context,
          content: res ?? 'Request processed successfully',
        );
      },
    );
  }
}
