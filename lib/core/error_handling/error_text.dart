import 'package:flutter/material.dart';
import '../../features/auth/screens/createPin_screen.dart';
import '../common/alert_dialog/alertBox_function.dart';
import '../network_connection_checker/connectivity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/NavigationService.dart';
// class ErrorText extends StatefulWidget {
//   final String errorText;
//
//   const ErrorText({super.key, required this.errorText});
//
//   @override
//   State<ErrorText> createState() => _ErrorTextState();
// }
//
// class _ErrorTextState extends State<ErrorText> {
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.errorText.toLowerCase().contains("no internet connection")) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _showPopup();
//         }
//       });
//     }
//   }
//
//   Future<void> _showPopup() async {
//     showNoInternetPopup(
//       context: context,
//       onPressed: () async {
//         Navigator.of(context).pop(); // close current dialog
//         final connectivityService = ConnectivityService();
//         final hasInternet = await connectivityService.hasInternet();
//         if (!hasInternet && mounted) {
//           _showPopup(); // 🔄 show again until internet is back
//         }
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SelectableText(
//         widget.errorText,
//         style: const TextStyle(color: Colors.red, fontSize: 16.0),
//         showCursor: true,
//         cursorColor: Colors.blue,
//         toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
//       ),
//     );
//   }
// }

class ErrorText extends ConsumerStatefulWidget {
  final String errorText;

  const ErrorText({super.key, required this.errorText});

  @override
  ConsumerState<ErrorText> createState() => _ErrorHandlerState();
}

class _ErrorHandlerState extends ConsumerState<ErrorText> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final error = widget.errorText.toLowerCase();

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
      title: "SERVER CONNECTION LOST !",
      type: AlertType.error,
      barrierDismissible: false,
      showCloseButton: false,

      primaryButtonText: 'Retry',
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
