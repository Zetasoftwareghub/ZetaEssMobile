import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasInternet() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}

Future<void> handleNoInternet({
  required BuildContext context,
  required VoidCallback onConnected,
}) async {
  final connectivityService = ConnectivityService();
  final hasInternet = await connectivityService.hasInternet();

  if (!hasInternet) {
    if (!context.mounted) return;
    showNoInternetPopup(
      context: context,
      onPressed: () async {
        Navigator.of(context).pop();
        final retryInternet = await connectivityService.hasInternet();
        if (retryInternet && context.mounted) {
          onConnected();
        } else {
          handleNoInternet(context: context, onConnected: onConnected);
        }
      },
    );
  } else {
    onConnected();
  }
}

void showNoInternetPopup({
  required void Function()? onPressed,
  required BuildContext context,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "No Internet",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink(); // required but not used
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return ScaleTransition(
        scale: curvedAnimation,
        child: Center(
          child: WillPopScope(
            onWillPop: () async => false,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔥 Animated Wifi / No Internet Icon
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No Internet Connection",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "It looks like you are offline.\nPlease check your network settings.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Retry Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: onPressed,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        "Retry",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
