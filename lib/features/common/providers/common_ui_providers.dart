import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:zeta_ess/features/common/models/mainMenus_model.dart';
import 'package:zeta_ess/features/common/models/notification_model.dart';

import '../../../core/providers/userContext_provider.dart';
import '../models/announcement_model.dart';
import '../models/download_model.dart';
import '../models/leaveBalance_model.dart';
import '../repository/common_repository.dart';
import '../repository/employee_repository.dart';

///PAYSLIP
final paySlipsListProvider = AsyncNotifierProvider.autoDispose
    .family<PaySlipsListNotifier, List<DocumentModel>, String>(
      PaySlipsListNotifier.new,
    );

class PaySlipsListNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<DocumentModel>, String> {
  @override
  Future<List<DocumentModel>> build(String year) async {
    final userContext = ref.read(userContextProvider);
    return _getPaySlips(userContext, year);
  }

  Future<List<DocumentModel>> _getPaySlips(
    UserContext userContext,
    String year,
  ) async {
    final repo = ref.read(commonRepositoryProvider);
    final result = await repo.getPaySlips(userContext: userContext, year: year);

    return result.fold(
      (failure) => throw Exception(failure.errMsg),
      (data) => data,
    );
  }
}

///DOWNLOAD
final downloadListProvider = AsyncNotifierProvider.autoDispose<
  DownloadListNotifier,
  List<DocumentModel>
>(DownloadListNotifier.new);

class DownloadListNotifier
    extends AutoDisposeAsyncNotifier<List<DocumentModel>> {
  @override
  Future<List<DocumentModel>> build() async {
    final userContext = ref.read(userContextProvider);
    return _getDownloads(userContext);
  }

  Future<List<DocumentModel>> _getDownloads(UserContext userContext) async {
    final repo = ref.read(commonRepositoryProvider);

    final result = await repo.getDownloads(userContext: userContext);
    return result.fold(
      (failure) => throw Exception(failure.errMsg),
      (data) => data,
    );
  }
}

///ANNOUNCEMENT
final announcementProvider =
    FutureProvider.autoDispose<List<AnnouncementModel>>((ref) async {
      final repo = ref.read(commonRepositoryProvider);
      final userContext = ref.read(userContextProvider);

      final result = await repo.getAnnouncements(userContext: userContext);

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (leaveList) => leaveList,
      );
    });

final getPendingRequestNotificationProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
      final repo = ref.read(commonRepositoryProvider);
      final userContext = ref.read(userContextProvider);

      final result = await repo.getPendingRequestNotification(
        userContext: userContext,
      );

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (leaveList) => leaveList,
      );
    });

final getPendingApprovalsNotificationProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
      final repo = ref.read(commonRepositoryProvider);
      final userContext = ref.read(userContextProvider);

      final result = await repo.getPendingApprovalsNotification(
        userContext: userContext,
      );

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (leaveList) => leaveList,
      );
    });

///LEAVE BALANCE
final leaveBalanceProvider =
    FutureProvider.autoDispose<List<LeaveBalanceModel>>((ref) async {
      final repo = ref.read(employeeRepositoryProvider);
      final userContext = ref.read(userContextProvider);

      final result = await repo.getLeaveBalance(userContext: userContext);

      return result.fold(
        (failure) => throw Exception(failure.errMsg),
        (leaveList) => leaveList,
      );
    });

final menuAgainstEmployeeProvider = FutureProvider.autoDispose<MainMenuModel>((
  ref,
) async {
  final repo = ref.read(employeeRepositoryProvider);
  final userContext = ref.read(userContextProvider);

  final result = await repo.getMainMenuAgainstEmployee(
    userContext: userContext,
  );

  return result.fold(
    (failure) => throw Exception(failure.errMsg),
    (mainMenu) => mainMenu,
  );
});
