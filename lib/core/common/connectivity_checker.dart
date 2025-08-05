// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
//
// import '../theme/app_theme.dart';
// import '../utils.dart';
//
// final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
//   return Connectivity().onConnectivityChanged;
// });
//
// class ConnectivityListener extends ConsumerWidget {
//   final Widget child;
//
//   ConnectivityListener({required this.child});
//
//   static bool _isDialogOpen = false;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final connectivityStatus = ref.watch(connectivityProvider);
//
//     connectivityStatus.when(
//       data: (connectivityResults) {
//         if (connectivityResults.isEmpty ||
//             connectivityResults.first == ConnectivityResult.none) {
//           if (!_isDialogOpen) {
//             _isDialogOpen = true;
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               showNoInternetAlert(context, () {
//                 ref.refresh(connectivityProvider);
//               });
//             });
//           }
//         } else {
//           if (_isDialogOpen) {
//             Navigator.of(context, rootNavigator: true).pop();
//             _isDialogOpen = false;
//           }
//         }
//       },
//       loading: () {},
//       error: (err, stack) {},
//     );
//
//     return child; // Return the child widget (whole app)
//   }
// }
//
// void showNoInternetAlert(context, VoidCallback onRetry) {
//   showCustomAlertBox(
//     context,
//     type: AlertType.error,
//     title: 'connection_lost'.tr(),
//     content: 'no_internet'.tr(),
//     primaryButtonText: 'retry'.tr(),
//     onPrimaryPressed: () async {
//       await Connectivity().checkConnectivity().then((value) {
//         if (value.any((e) => e == ConnectivityResult.none)) {
//           showSnackBar(
//             content: 'still_no_internet'.tr(),
//             context: context,
//             color: AppTheme.errorColor,
//           );
//         } else {
//           Navigator.of(context, rootNavigator: true).pop();
//           onRetry();
//           ConnectivityListener._isDialogOpen = false;
//         }
//       });
//     },
//   );
// }

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../utils.dart';
import 'alert_dialog/alertBox_function.dart';

final connectivityProvider =
    StreamProvider.autoDispose<List<ConnectivityResult>>((ref) {
      return Connectivity().onConnectivityChanged;
    });

class ConnectivityListener extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectivityListener({super.key, required this.child});

  @override
  ConsumerState<ConnectivityListener> createState() =>
      _ConnectivityListenerState();
}

class _ConnectivityListenerState extends ConsumerState<ConnectivityListener> {
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();

    // Listen to connectivity changes
    Future.delayed(Duration.zero, () {
      ref.listen(connectivityProvider, (previous, next) {
        final result = next.asData?.value;

        if (result == null ||
            result.isEmpty ||
            result.first == ConnectivityResult.none) {
          _showNoInternetDialog();
        } else {
          _closeDialogIfOpen();
        }
      });
    });
  }

  void _showNoInternetDialog() {
    if (_isDialogOpen || !mounted) return;

    _isDialogOpen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showNoInternetAlert(context, () {
        ref.invalidate(connectivityProvider); // Triggers retry
      });
    });
  }

  void _closeDialogIfOpen() {
    if (_isDialogOpen && mounted) {
      Navigator.of(context, rootNavigator: true).maybePop();
      _isDialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

void showNoInternetAlert(BuildContext context, VoidCallback onRetry) {
  if (ModalRoute.of(context)?.isCurrent != true) return;

  showCustomAlertBox(
    context,
    type: AlertType.error,
    title: 'connection_lost'.tr(),
    content: 'no_internet'.tr(),
    primaryButtonText: 'retry'.tr(),
    onPrimaryPressed: () async {
      final result = await Connectivity().checkConnectivity();
      if (result.any((e) => e == ConnectivityResult.none)) {
        showSnackBar(
          content: 'still_no_internet'.tr(),
          context: context,
          color: AppTheme.errorColor,
        );
      } else {
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        onRetry();
      }
    },
  );
}
