import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/auth/screens/createPin_screen.dart';
import 'package:zeta_ess/features/common/screens/main_screen.dart';

import '../network_connection_checker/connectivity_service.dart';

class ErrorText extends ConsumerStatefulWidget {
  final String error;

  const ErrorText({super.key, required this.error});

  @override
  ConsumerState<ErrorText> createState() => _ErrorHandlerState();
}

class _ErrorHandlerState extends ConsumerState<ErrorText> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final error = widget.error.toLowerCase();

      if (error.contains("no internet connection") ||
          error.contains("instance")) {
        _showNoInternetPopup();
      } else {
        _showServerErrorPopup();
      }
    });
  }

  Future<void> _showNoInternetPopup() async {
    showNoInternetPopup(
      context: context,
      onPressed: () async {
        Navigator.of(context).pop();

        final connectivityService = ConnectivityService();
        final hasInternet = await connectivityService.hasInternet();

        if (!mounted) return;

        if (!hasInternet) {
          _showNoInternetPopup(); // 🔄 keep showing until internet is back
        } else {
          NavigationService.navigateRemoveUntil(
            context: context,
            screen: const CreatePinScreen(),
          );
        }
      },
    );
  }

  Future<void> _showServerErrorPopup() async {
    showCustomAlertBox(
      context,
      title: "SERVER CONNECTION LOST !".tr(),
      type: AlertType.error,
      barrierDismissible: false,
      showCloseButton: false,
      primaryButtonText: 'retry'.tr(),
      onPrimaryPressed: () {
        NavigationService.navigateRemoveUntil(
          context: context,
          screen: CreatePinScreen(),
        );
        // Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⛔ No error text shown in UI anymore
    return const SizedBox.shrink();
  }
}
