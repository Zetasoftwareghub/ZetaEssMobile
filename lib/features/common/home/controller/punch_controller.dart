import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../../../core/providers/userContext_provider.dart';
import '../../models/punch_model.dart';
import '../repository/home_repository.dart';
import 'liveLocation_controller.dart';

class PunchDetailsProvider extends AutoDisposeAsyncNotifier<List<PunchModel>> {
  @override
  FutureOr<List<PunchModel>> build() async {
    final repo = ref.read(homeRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final result = await repo.getPunchDetails(userContext: userContext);
    return result.fold(
      (failure) => throw Exception(failure.errMsg),
      (data) => data,
    );
  }
}

class SavePunchNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async => '';

  Future<void> save({
    required LiveLocation loc,
    required String ipAddress,
    required String locationTime,
    required BuildContext context,
    required bool isCheckIn,
    List<PunchModel> punchDetails = const [],
  }) async {
    state = const AsyncLoading();

    final userContext = ref.read(userContextProvider);
    final repo = ref.read(homeRepositoryProvider);

    final result = await repo.savePunch(
      userContext: userContext,
      loc: loc,
      ipAddress: ipAddress,
      locationTime: locationTime,
    );

    result.fold(
      (failure) {
        state = AsyncError(failure.errMsg, StackTrace.current);
        showCustomAlertBox(context, title: failure.errMsg);
      },
      (response) {
        AlertType alertType;
        String message = '';
        final responseString = isCheckIn ? "Checked In" : "Checked Out";

        if (response == "I" || response == "O" || response == "0") {
          message = "Successfully $responseString";
          alertType = AlertType.success;
          if (response == "0") {
            message = "Already $responseString";
            if (punchDetails.isNotEmpty) {
              final punchType = punchDetails.first.punchType;
              message = "Already checked $punchType";
            }
            alertType = AlertType.warning;
          }
        } else if (response == "25") {
          message = 'Invalid alternative id';
          alertType = AlertType.error;
        } else {
          message = response;
          alertType = AlertType.error;
        }

        state = AsyncData(response);
        showCustomAlertBox(
          context,
          title: message,
          content:
              alertType == AlertType.error
                  ? "Lat: ${loc.position.latitude}, Long: ${loc.position.longitude} \n EMP code: ${userContext.empCode}"
                  : null,
          type: alertType,
        );
      },
    );
  }
}
