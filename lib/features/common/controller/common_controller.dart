import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/features/common/repository/common_repository.dart';

import '../../../core/providers/userContext_provider.dart';
import '../../../core/utils.dart';

final commonControllerProvider = NotifierProvider<CommonController, bool>(
  () => CommonController(),
);

class CommonController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> launchPayslipDownloadUrl({
    required BuildContext context,
    required String year,
    required String monthName,
  }) async {
    state = true;
    final res = await ref
        .read(commonRepositoryProvider)
        .paySlipDownloadUrl(
          userContext: ref.watch(userContextProvider),
          year: year,
          monthName: monthName,
        );
    state = false;

    res.fold(
      (l) {
        showSnackBar(
          context: context,
          content: 'Failed to get URL: ${l.errMsg}',
          color: AppTheme.errorColor,
        );
      },
      (url) async {
        if (url != null && url.isNotEmpty) {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            showSnackBar(
              context: context,
              content: 'Could not launch URL',
              color: AppTheme.errorColor,
            );
          }
        } else {
          showSnackBar(
            context: context,
            content: 'No URL returned from server',
            color: AppTheme.errorColor,
          );
        }
      },
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(commonRepositoryProvider)
        .changePassword(
          userContext: ref.watch(userContextProvider),
          oldPassword: oldPassword,
          newPassword: newPassword,
        );
    state = false;
    return res.fold(
      (l) {
        state = false;
        showSnackBar(
          context: context,
          content: 'Error occurred in change password: ${l.errMsg}',
        );
      },
      (changed) {
        showCustomAlertBox(
          context,
          title:
              changed == '1'
                  ? 'Changed password successfully'
                  : (changed ?? 'Something went wrong, try again later'),
          type: changed == '1' ? AlertType.success : AlertType.error,
        );
      },
    );
  }
}
