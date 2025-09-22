import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/alert_dialog/alertBox_function.dart';
import '../controller/liveLocation_controller.dart';

class CustomLocationRetryButton extends ConsumerStatefulWidget {
  const CustomLocationRetryButton({super.key});

  @override
  ConsumerState<CustomLocationRetryButton> createState() =>
      _CustomLocationRetryButtonState();
}

class _CustomLocationRetryButtonState
    extends ConsumerState<CustomLocationRetryButton>
    with WidgetsBindingObserver {
  bool _waitingForLocationSettings = false;
  bool _waitingForAppSettings = false;

  @override
  void initState() {
    super.initState();
    // Add app lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes from background
    if (state == AppLifecycleState.resumed) {
      if (_waitingForLocationSettings || _waitingForAppSettings) {
        // Reset waiting flags
        _waitingForLocationSettings = false;
        _waitingForAppSettings = false;

        // Retry getting location after a short delay
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            ref.read(liveLocationControllerProvider.notifier).retry();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final notifier = ref.read(liveLocationControllerProvider.notifier);
        final status = await notifier.getLocationStatus();

        if (!status['serviceEnabled']) {
          showCustomAlertBox(
            context,
            title: 'Location Services Required',
            content: 'Please enable location services in your device settings.',
            type: AlertType.warning,
            primaryButtonText: 'Open Settings',
            onPrimaryPressed: () async {
              Navigator.pop(context);
              if (status['needsAppSettings']) {
                _waitingForAppSettings = true;
                await notifier.openAppSettings();
              } else {
                _waitingForLocationSettings = true;
                await notifier.openLocationSettings();
              }
            },
          );
        } else {
          // Normal retry - immediate
          await notifier.manualRetry();
        }
      },
      child: Text('retry'.tr()),
    );
  }
}

// Alternative approach: Global App State Listener
// Add this to your main app or a high-level widget

class AppLifecycleLocationListener extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleLocationListener({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleLocationListener> createState() =>
      _AppLifecycleLocationListenerState();
}

class _AppLifecycleLocationListenerState
    extends ConsumerState<AppLifecycleLocationListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Check if location provider is in error state
      final locationState = ref.read(liveLocationControllerProvider);
      if (locationState.hasError) {
        // Automatically retry when app resumes if there was an error
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ref.read(liveLocationControllerProvider.notifier).retry();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Usage: Wrap your MaterialApp or main screen with:
// AppLifecycleLocationListener(
//   child: YourMainWidget(),
// )

// Alternative: Using a hook-based approach if you use flutter_hooks
// class LocationRetryHook extends HookConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     useOnAppLifecycleStateChange((previous, current) {
//       if (current == AppLifecycleState.resumed) {
//         final locationState = ref.read(liveLocationControllerProvider);
//         if (locationState.hasError) {
//           Future.delayed(const Duration(milliseconds: 500), () {
//             ref.read(liveLocationControllerProvider.notifier).retry();
//           });
//         }
//       }
//     });
//
//     return YourWidget();
//   }
// }

/*
ENHANCED CODE but below is working fine
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../controller/liveLocation_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomLocationRetryButton extends ConsumerStatefulWidget {
  const CustomLocationRetryButton({super.key});

  @override
  ConsumerState<CustomLocationRetryButton> createState() =>
      _CustomLocationRetryButtonState();
}

class _CustomLocationRetryButtonState
    extends ConsumerState<CustomLocationRetryButton>
    with WidgetsBindingObserver {
  bool _waitingForLocationSettings = false;
  bool _waitingForAppSettings = false;

  @override
  void initState() {
    super.initState();
    // Add app lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes from background
    if (state == AppLifecycleState.resumed) {
      if (_waitingForLocationSettings || _waitingForAppSettings) {
        // Reset waiting flags
        _waitingForLocationSettings = false;
        _waitingForAppSettings = false;

        // Retry getting location after a short delay
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            ref.read(liveLocationControllerProvider.notifier).retry();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final notifier = ref.read(liveLocationControllerProvider.notifier);
        final status = await notifier.getLocationStatus();

        if (!status['serviceEnabled']) {
          // Show dialog for location services
          final shouldOpen = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Location Services Required'),
                  content: const Text(
                    'Please enable location services in your device settings.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
          );

          if (shouldOpen == true) {
            // Set flag that we're waiting for location settings
            _waitingForLocationSettings = true;
            await notifier.openLocationSettings();
            // Don't call retry here - let the app lifecycle handle it
          }
        } else if (status['needsAppSettings']) {
          // Show dialog for app permission
          final shouldOpen = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Location Permission Required'),
                  content: const Text(
                    'Please enable location permission in app settings.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('App Settings'),
                    ),
                  ],
                ),
          );

          if (shouldOpen == true) {
            // Set flag that we're waiting for app settings
            _waitingForAppSettings = true;
            await notifier.openAppSettings();
            // Don't call retry here - let the app lifecycle handle it
          }
        } else {
          // Normal retry - immediate
          await notifier.manualRetry();
        }
      },
      child: Text('retry'.tr()),
    );
  }
}

// Alternative approach: Global App State Listener
// Add this to your main app or a high-level widget

class AppLifecycleLocationListener extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleLocationListener({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleLocationListener> createState() =>
      _AppLifecycleLocationListenerState();
}

class _AppLifecycleLocationListenerState
    extends ConsumerState<AppLifecycleLocationListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Check if location provider is in error state
      final locationState = ref.read(liveLocationControllerProvider);
      if (locationState.hasError) {
        // Automatically retry when app resumes if there was an error
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ref.read(liveLocationControllerProvider.notifier).retry();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
 */
