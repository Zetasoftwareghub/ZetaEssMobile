import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/providers/userContext_provider.dart';
import '../models/approve_attendance_regularisation_listing_model.dart';
import '../repository/approve_attendance_regularisation_repository.dart';

final approveRegulariseControllerProvider =
    NotifierProvider<AttendanceRegulariseController, bool>(() {
      return AttendanceRegulariseController();
    });

class AttendanceRegulariseController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> approveRejectRegularise({
    required BuildContext context,
    required String note,
    required String requestId,
    required String strEmailId,
    required String approveRejectFlag,
  }) async {
    final repo = ref.read(approveAttendanceRegularisationRepositoryProvider);
    final userContext = ref.read(userContextProvider);
    state = true;
    final res = await repo.approveRejectRegularisation(
      requestId: requestId,
      strEmailId: strEmailId,
      approveRejectFlag: approveRejectFlag,
      note: note,
      userContext: userContext,
    );
    state = false;
    return res.fold(
      (l) {
        showSnackBar(context: context, content: 'Error occurred: ${l.errMsg}');
      },
      // (response) {
      //   ref.invalidate(approveAttendanceRegularisationListProvider);
      //   if (response ==
      //           'Attendance regularization request approved successfully' ||
      //       response ==
      //           'Attendance regularization request rejected successfully') {
      //     Navigator.pop(context);
      //   }
      //   showSnackBar(context: context, content: response ?? 'Error occured');
      // },
      (response) {
        ref.invalidate(approveAttendanceRegularisationListProvider);

        final returnVal = int.tryParse(response ?? '0') ?? 0;

        String resultMessage;
        if (approveRejectFlag == "A") {
          if (returnVal > 0) {
            Navigator.pop(context);
            resultMessage =
                "Attendance regularization request approved successfully";
          } else {
            resultMessage =
                "Could not approve attendance regularization request!";
          }
        } else {
          if (returnVal > 0) {
            Navigator.pop(context);
            resultMessage =
                "Attendance regularization request rejected successfully";
          } else {
            resultMessage =
                "Could not reject attendance regularization request";
          }
        }

        showSnackBar(context: context, content: resultMessage.tr());
      },
    );
  }
}

final approveAttendanceRegularisationListProvider =
    AutoDisposeAsyncNotifierProvider<
      ApproveAttendanceRegularisationListNotifier,
      ApproveAttendanceRegularisationListResponse
    >(ApproveAttendanceRegularisationListNotifier.new);

class ApproveAttendanceRegularisationListNotifier
    extends
        AutoDisposeAsyncNotifier<ApproveAttendanceRegularisationListResponse> {
  @override
  Future<ApproveAttendanceRegularisationListResponse> build() async {
    final userContext = ref.read(userContextProvider);
    final repo = ref.read(approveAttendanceRegularisationRepositoryProvider);
    final result = await repo.getApproveAttendanceRegularisationList(
      userContext: userContext,
    );
    return result.fold((failure) => throw failure, (data) => data);
  }
}
