/*
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zeta_ess/core/api_constants/keys/storage_keys.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/auth/screens/login_screen.dart';
import 'package:zeta_ess/services/secure_stroage_service.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils.dart';
import '../models/local_auth.dart';
import '../repository/auth_repository.dart';
import '../screens/widgets/snackbar_failure_pinscreen.dart';
import 'auth_controller.dart';

final localAuthProvider = NotifierProvider<LocalAuthNotifier, LocalAuthState>(
  () => LocalAuthNotifier(),
);

/// Three distinct outcomes from the activation check.
/// This is the key fix — previously networkError and unauthorized
/// were treated the same way (both caused logout).
enum ActivationStatus { authorized, unauthorized, networkError }

class LocalAuthNotifier extends Notifier<LocalAuthState> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  LocalAuthState build() {
    Future.microtask(() => loadInitialAuthState());
    return LocalAuthState();
  }

  // ─────────────────────────────────────────────
  // Initial state
  // ─────────────────────────────────────────────

  Future<void> loadInitialAuthState() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('🔥 FCM Token: $fcmToken');

    final localUrl = await SecureStorageService.read(key: StorageKeys.baseUrl);
    ref.read(baseUrlProvider.notifier).state = localUrl ?? '';

    final savedPin = await SecureStorageService.read(key: StorageKeys.userPin);
    final biometricFlag = await SecureStorageService.read(
      key: StorageKeys.biometricKey,
    );

    state = state.copyWith(
      hasPin: savedPin != null,
      urlExist: localUrl?.startsWith('http'),
      isAuthenticated: biometricFlag == 'true',
      savedPin: savedPin,
    );
  }

  // ─────────────────────────────────────────────
  // PIN
  // ─────────────────────────────────────────────

  Future<void> savePin(String pin) async {
    await SecureStorageService.write(key: StorageKeys.userPin, value: pin);
    state = state.copyWith(hasPin: true);
  }

  /// Verifies PIN locally, but also validates the activation URL first.
  /// Uses the retry-aware check so a momentary network blip won't
  /// log the user out mid-PIN entry.
  Future<bool> verifyPin(String inputPin, BuildContext context) async {
    final savedPin = await SecureStorageService.read(key: StorageKeys.userPin);

    final activationStatus = await _checkActivationWithRetry(
      context,
      maxRetries: 3,
    );

    if (activationStatus == ActivationStatus.networkError) {
      _showTopSnackBarWithRetry(
        context: context,
        message: 'Connection issue. Please check your network and try again.',
        onRetry: () => verifyPin(inputPin, context),
      );
      return false;
    }

    if (activationStatus == ActivationStatus.unauthorized) {
      await SecureStorageService.clearAll();
      NavigationService.navigateRemoveUntil(
        context: context,
        screen: LoginScreen(),
      );
      return false;
    }

    return inputPin == savedPin;
  }

  // ─────────────────────────────────────────────
  // Biometrics
  // ─────────────────────────────────────────────

  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    // Step 1 — hardware check first, no network needed
    final canUseBiometrics = await auth.canCheckBiometrics;
    final isDeviceSupported = await auth.isDeviceSupported();
    if (!canUseBiometrics || !isDeviceSupported) return false;

    // Step 2 — activation check with retry tolerance
    final activationStatus = await _checkActivationWithRetry(
      context,
      maxRetries: 3,
    );

    if (activationStatus == ActivationStatus.networkError) {
      // Network hiccup — stay on PIN screen, let user retry
      _showTopSnackBarWithRetry(
        context: context,
        message: 'Connection issue. Please check your network and try again.',
        onRetry: () => authenticateWithBiometrics(context),
      );
      return false;
    }

    if (activationStatus == ActivationStatus.unauthorized) {
      // Truly deactivated — safe to clear session
      await SecureStorageService.clearAll();
      NavigationService.navigateRemoveUntil(
        context: context,
        screen: LoginScreen(),
      );
      return false;
    }

    // Step 3 — biometric prompt
    final authenticated = await auth.authenticate(
      localizedReason: 'ZETA HRMS Biometric Auth',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (authenticated) {
      await SecureStorageService.write(
        key: StorageKeys.biometricKey,
        value: 'true',
      );

      final user = ref.read(userDataProvider);

      // Guard against wiped/missing credentials
      if (user == null || user.userName.isEmpty || user.password.isEmpty) {
        _showTopSnackBarWithRetry(
          context: context,
          message: 'Session data missing. Please log in again.',
          onRetry: null, // nothing to retry — must log in manually
        );
        return false;
      }

      // Awaited so errors surface; fromPinScreen skips the normal
      // post-login navigation that would double-push MainScreen
      await ref
          .read(authControllerProvider.notifier)
          .loginUser(
            userName: user.userName,
            password: user.password,
            context: context,
            fromPinScreen: true,
          );

      state = state.copyWith(isAuthenticated: true);
    }

    return authenticated;
  }

  // ─────────────────────────────────────────────
  // Activation check — retry-aware
  // ─────────────────────────────────────────────

  /// Retries up to [maxRetries] times with exponential backoff (2 s, 4 s).
  /// Only retries on network errors; unauthorized stops immediately.
  Future<ActivationStatus> _checkActivationWithRetry(
    BuildContext context, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      attempt++;

      final url = await SecureStorageService.read(key: StorageKeys.baseUrl);
      final res = await ref
          .read(authRepositoryProvider)
          .activateUrl(url: url ?? '');

      final status = res.fold<ActivationStatus>(
        (failure) {
          debugPrint('[Attempt $attempt] Network error: ${failure.errMsg}');
          return ActivationStatus.networkError;
        },
        (activateResponse) {
          if (activateResponse['data'] != 'Authorized') {
            debugPrint('[Attempt $attempt] Unauthorized');
            return ActivationStatus.unauthorized;
          }
          return ActivationStatus.authorized;
        },
      );

      // Authorized or unauthorized → no point retrying
      if (status != ActivationStatus.networkError) return status;

      // Exponential backoff before next attempt
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    // All retries exhausted — still treat as network error, NOT unauthorized
    return ActivationStatus.networkError;
  }

  // ─────────────────────────────────────────────
  // Top snackbar with optional retry button
  // ─────────────────────────────────────────────

  /// Shows a top-sliding overlay snackbar.
  /// Pass [onRetry] to display the Retry button; pass null to hide it
  /// (e.g. for "session data missing" where manual login is required).
  void _showTopSnackBarWithRetry({
    required BuildContext context,
    required String message,
    required VoidCallback? onRetry,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => TopSnackBar(
            message: message,
            onRetry:
                onRetry == null
                    ? null
                    : () {
                      overlayEntry.remove();
                      onRetry();
                    },
            onDismiss: () {
              if (overlayEntry.mounted) overlayEntry.remove();
            },
          ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after 6 s if the user doesn't interact
    Future.delayed(const Duration(seconds: 6), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }
}

*/

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zeta_ess/core/api_constants/keys/storage_keys.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/auth/screens/activationUrl_screen.dart';
import 'package:zeta_ess/features/auth/screens/login_screen.dart';
import 'package:zeta_ess/services/secure_stroage_service.dart';

import '../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils.dart';
import '../../common/screens/main_screen.dart';
import '../models/local_auth.dart';
import '../repository/auth_repository.dart';
import '../screens/widgets/snackbar_failure_pinscreen.dart';
import 'auth_controller.dart';

final localAuthProvider = NotifierProvider<LocalAuthNotifier, LocalAuthState>(
  () => LocalAuthNotifier(),
);

enum ActivationStatus { authorized, unauthorized, networkError }

class LocalAuthNotifier extends Notifier<LocalAuthState> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  LocalAuthState build() {
    Future.microtask(() => loadInitialAuthState());
    return LocalAuthState();
  }

  Future<void> loadInitialAuthState() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("🔥 FCM Token fetched inside LocalAuthNotifier: $fcmToken");

    final localUrl = await SecureStorageService.read(key: StorageKeys.baseUrl);
    ref.read(baseUrlProvider.notifier).state = localUrl ?? '';

    final savedPin = await SecureStorageService.read(key: StorageKeys.userPin);
    final biometricFlag = await SecureStorageService.read(
      key: StorageKeys.biometricKey,
    );

    state = state.copyWith(
      hasPin: savedPin != null,
      urlExist: localUrl?.startsWith('http'),
      isAuthenticated: biometricFlag == 'true',
      savedPin: savedPin,
    );
  }

  Future<void> savePin(String pin) async {
    await SecureStorageService.write(key: StorageKeys.userPin, value: pin);
    state = state.copyWith(hasPin: true);
  }

  Future<bool> verifyPin(String inputPin, context) async {
    final savedPin = await SecureStorageService.read(key: StorageKeys.userPin);

    final isActivated = await _checkActivationAndNavigateIfNeeded(context);
    if (!isActivated) return false;

    return inputPin == savedPin;
  }

  //TODO changed this to handle network errors gracefully without logging out users immediately !! CLAUDE gave below next funciton
  // Future<bool> authenticateWithBiometrics(BuildContext context) async {
  //   final canUseBiometrics = await auth.canCheckBiometrics;
  //   final isDeviceSupported = await auth.isDeviceSupported();
  //
  //   final isActivated = await _checkActivationAndNavigateIfNeeded(context);
  //   if (!isActivated) return false;
  //
  //   if (!canUseBiometrics || !isDeviceSupported) return false;
  //
  //   final authenticated = await auth.authenticate(
  //     localizedReason: 'ZETA HRMS Biometric Auth',
  //     options: const AuthenticationOptions(biometricOnly: true),
  //   );
  //   if (authenticated) {
  //     await SecureStorageService.write(
  //       key: StorageKeys.biometricKey,
  //       value: 'true',
  //     );
  //     final user = ref.read(userDataProvider);
  //
  //     if (user != null) {
  //       ref
  //           .read(authControllerProvider.notifier)
  //           .loginUser(
  //             userName: user.userName,
  //             password: user.password,
  //             context: context,
  //             fromPinScreen: true,
  //           );
  //     }
  //     state = state.copyWith(isAuthenticated: true);
  //   }
  //
  //   return authenticated;
  // }
  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    // 1. Check biometric hardware first — no network needed
    final canUseBiometrics = await auth.canCheckBiometrics;
    final isDeviceSupported = await auth.isDeviceSupported();
    if (!canUseBiometrics || !isDeviceSupported) return false;

    // 2. Activation check with retry tolerance (3 attempts)
    final activationStatus = await _checkActivationWithRetry(
      context,
      maxRetries: 3,
    );

    if (activationStatus == ActivationStatus.networkError) {
      // Network issue — don't log out, show snackbar with retry
      _showTopSnackBarWithRetry(
        context: context,
        message: 'Connection issue. Please check your network and try again.',
      );
      return false;
    }

    if (activationStatus == ActivationStatus.unauthorized) {
      // Truly unauthorized — safe to clear and navigate
      await SecureStorageService.clearAll();
      NavigationService.navigateRemoveUntil(
        context: context,
        screen: LoginScreen(),
      );
      return false;
    }

    // 3. Proceed with biometric prompt
    final authenticated = await auth.authenticate(
      localizedReason: 'ZETA HRMS Biometric Auth',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (authenticated) {
      await SecureStorageService.write(
        key: StorageKeys.biometricKey,
        value: 'true',
      );

      final user = ref.read(userDataProvider);

      // Guard against wiped credentials
      if (user == null || user.userName.isEmpty || user.password.isEmpty) {
        _showTopSnackBarWithRetry(
          context: context,
          message: 'Session data missing. Please log in again.',
        );
        return false;
      }

      ref
          .read(authControllerProvider.notifier)
          .loginUser(
            userName: user.userName,
            password: user.password,
            context: context,
            fromPinScreen: true,
          );

      state = state.copyWith(isAuthenticated: true);
    }

    return authenticated;
  }

  Future<ActivationStatus> _checkActivationWithRetry(
    BuildContext context, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      attempt++;

      final url = await SecureStorageService.read(key: StorageKeys.baseUrl);
      final res = await ref
          .read(authRepositoryProvider)
          .activateUrl(url: url ?? '');

      final status = res.fold<ActivationStatus>(
        (failure) {
          print(
            '[Attempt $attempt] Activation network error: ${failure.errMsg}',
          );
          // Treat as network error, NOT unauthorized
          return ActivationStatus.networkError;
        },
        (activateResponse) {
          if (activateResponse["data"] != "Authorized") {
            print('[Attempt $attempt] Activation unauthorized');
            return ActivationStatus.unauthorized;
          }
          return ActivationStatus.authorized;
        },
      );

      // Only retry on network errors, never on unauthorized
      if (status == ActivationStatus.authorized ||
          status == ActivationStatus.unauthorized) {
        return status;
      }

      // Wait before retry with exponential backoff
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2)); // 2s, 4s
      }
    }

    // All retries exhausted — still a network error, not unauthorized
    return ActivationStatus.networkError;
  }

  Future<bool> _checkActivationAndNavigateIfNeeded(BuildContext context) async {
    final url = await SecureStorageService.read(key: StorageKeys.baseUrl);
    final res = await ref
        .read(authRepositoryProvider)
        .activateUrl(url: url ?? '');

    bool isAuthorized = false;

    res.fold(
      (failure) {
        print(failure.errMsg);
        print("failure.errMsg");

        // Show top snackbar with retry — no navigation
        _showTopSnackBarWithRetry(context: context, message: failure.errMsg);
      },
      (activateResponse) {
        print(activateResponse);
        print("activateResponse");
        if (activateResponse["data"] != "Authorized") {
          NavigationService.navigateRemoveUntil(
            context: context,
            screen: LoginScreen(),
          );
          SecureStorageService.clearAll();
        } else {
          isAuthorized = true;
        }
      },
    );

    return isAuthorized;
  }

  void _showTopSnackBarWithRetry({
    required BuildContext context,
    required String message,
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => TopSnackBar(
            message: message,
            onRetry: () {
              overlayEntry.remove();
              // Re-invoke the check on retry
              _checkActivationAndNavigateIfNeeded(context);
            },
            onDismiss: () {
              overlayEntry.remove();
            },
          ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after 6 seconds if user doesn't interact
    Future.delayed(const Duration(seconds: 6), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
