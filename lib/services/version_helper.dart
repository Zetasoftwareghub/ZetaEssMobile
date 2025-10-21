import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/utils.dart';
import '../features/common/models/version_check.dart';

class VersionHelper {
  static final String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.zeta.zeta_ess';
  static final String _appStoreUrl =
      'https://apps.apple.com/in/app/zeta-hrms/id1439102381'; //TODO change the url

  /// Checks if current app version is older than latest version
  static bool isNewer(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      final l = latestParts[i];
      final c = i < currentParts.length ? currentParts[i] : 0;

      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  /// Main method to check version and show dialog if needed
  static Future<void> checkAndShowUpdateDialog(
    BuildContext context,
    VersionModel? version,
  ) async {
    if (version == null) return;

    final latestVersion = version.latestVersion;
    final forceUpdate = version.forceUpdate;
    final message = version.message;

    // Get current app version
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    if (isNewer(latestVersion, currentVersion)) {
      showCustomAlertBox(
        context,
        title: 'Update Available',
        content: message,
        type: forceUpdate ? AlertType.error : AlertType.info,
        barrierDismissible: forceUpdate,
        showCloseButton: !forceUpdate,
        onSecondaryPressed:
            forceUpdate ? null : () => Navigator.of(context).pop(),
        primaryButtonText: 'Update',
        onPrimaryPressed: () async {
          final url = Platform.isAndroid ? _playStoreUrl : _appStoreUrl;

          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            );
          } else {
            showSnackBar(context: context, content: 'Could not open the store');
          }
        },
      );
    }
  }
}
