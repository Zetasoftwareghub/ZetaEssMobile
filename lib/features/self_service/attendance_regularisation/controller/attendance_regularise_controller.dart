import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/utils.dart';
import 'package:zeta_ess/features/self_service/attendance_regularisation/models/submit_regularise_model.dart';

import '../../../../core/common/no_server_screen.dart';
import '../../../../core/providers/userContext_provider.dart';
import '../../../../core/services/NavigationService.dart';
import '../repository/attendance_regularise_repository.dart';

class AttendanceRegulariseController extends Notifier<bool> {
  @override
  bool build() {
    // TODO: implement build
    return false;
  }

  Future<String?> submitRegulariseLeave({
    required SubmitRegulariseModel submitRequest,
    required BuildContext context,
  }) async {
    final repo = ref.read(attendanceRegulariseRepositoryProvider);
    final userContext = ref.read(userContextProvider);

    final res = await repo.submitRegulariseLeave(
      submitRequest: submitRequest,
      userContext: userContext,
    );

    return res.fold(
      (l) {
        NavigationService.navigateToScreen(
          context: context,
          screen: const NoServer(),
        );
        return null;
      },
      (response) {
        // if (response != null) showCustomAlertBox(context, title: response);
        return response;
      },
    );
  }

  Future<void> getCalendarDetails({required BuildContext context}) async {
    state = true;
    final res = await ref
        .read(attendanceRegulariseRepositoryProvider)
        .getCalendarDetails(
          userContext: ref.read(userContextProvider),
          regulariseDate: DateTime.now().toIso8601String(),
        );
    state = false;

    res.fold(
      (l) => showSnackBar(
        context: context,
        content: 'Failed to load calendar data',
      ),
      (details) {
        //TODO do the things here
      },
    );
  }
}

class CalendarNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  FutureOr<List<Map<String, dynamic>>> build() {
    // initially return empty or keep it suspended
    return [];
  }

  Future<void> fetchCalendarData({
    required String from,
    required String to,
    required UserContext userContext,
  }) async {
    final repository = ref.read(attendanceRegulariseRepositoryProvider);

    state = const AsyncLoading();

    final result = await repository.getCalendarData(
      dateFrom: from,
      dateTo: to,
      userContext: userContext,
    );

    result.fold(
      (failure) => state = AsyncError(failure.errMsg, StackTrace.current),
      (data) => state = AsyncData(data),
    );
  }
}
