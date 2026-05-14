import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zeta_ess/core/api_constants/keys/storage_keys.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';
import 'package:zeta_ess/services/secure_stroage_service.dart';
import '../../../core/utils.dart';
import '../models/local_auth.dart';
import 'auth_controller.dart';

final localAuthProvider = NotifierProvider<LocalAuthNotifier, LocalAuthState>(
  () => LocalAuthNotifier(),
);

/// Three distinct outcomes from the server activation check.
/// networkError → transient issue, never log the user out.
/// unauthorized → server explicitly revoked access, safe to clear session.
enum ActivationStatus { authorized, unauthorized, networkError }

class LocalAuthNotifier extends Notifier<LocalAuthState> {
  final LocalAuthentication _auth = LocalAuthentication();

  // In-memory PIN attempt counter — resets on successful login or app restart.
  int _failedPinAttempts = 0;
  static const int _maxPinAttempts = 10;

  // ─────────────────────────────────────────────
  // Riverpod lifecycle
  // ─────────────────────────────────────────────

  @override
  LocalAuthState build() {
    // Defer so the provider graph is fully built before we read from storage.
    Future.microtask(loadInitialAuthState);
    return LocalAuthState();
  }

  // ─────────────────────────────────────────────
  // Initial state — called once from splash / build()
  // ─────────────────────────────────────────────

  Future<void> loadInitialAuthState() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM token: $fcmToken');

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
    state = state.copyWith(hasPin: true, savedPin: pin);
  }

  /// Pure local comparison — no network, no navigation, no side-effects.
  /// The caller decides what to do with the result.
  Future<bool> verifyPin(String inputPin) async {
    if (_failedPinAttempts >= _maxPinAttempts) {
      // Locked out — caller should show lockout UI.
      return false;
    }

    final savedPin = await SecureStorageService.read(key: StorageKeys.userPin);
    final isValid = inputPin == savedPin;

    if (isValid) {
      _failedPinAttempts = 0; // Reset on success.
    } else {
      _failedPinAttempts++;
    }

    return isValid;
  }

  /// Whether the user has hit the maximum failed PIN attempts.
  bool get isPinLocked => _failedPinAttempts >= _maxPinAttempts;

  /// Reset lockout — call after a successful server login or explicit logout.
  void resetPinLockout() => _failedPinAttempts = 0;

  // ─────────────────────────────────────────────
  // Biometrics
  // ─────────────────────────────────────────────

  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    // 1. Hardware check — no network needed.
    final canUseBiometrics = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    if (!canUseBiometrics || !isDeviceSupported) return false;

    // 3. Show the OS biometric prompt.
    final authenticated = await _auth.authenticate(
      localizedReason: 'ZETA HRMS Biometric Auth',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (!authenticated) return false;

    // 4. Persist biometric flag.
    await SecureStorageService.write(
      key: StorageKeys.biometricKey,
      value: 'true',
    );

    // 5. Guard against wiped credentials before hitting the network.
    final user = ref.read(userDataProvider);
    if (user == null || user.userName.isEmpty || user.password.isEmpty) {
      showSnackBar(
        context: context,
        content: 'Session data missing. Please log in again.',
        color: AppTheme.errorColor,
      );
      return false;
    }

    // 6. ✅ Awaited — prevents the fire-and-forget race that caused
    //    LoginScreen to flash after CreatePinScreen.
    //    state update happens AFTER login resolves so isAuthenticated
    //    is only true once the server confirmed the session.
    if (context.mounted) {
      await ref
          .read(authControllerProvider.notifier)
          .loginUser(
            userName: user.userName,
            password: user.password,
            context: context,
            fromPinScreen: true,
          );
    }

    state = state.copyWith(isAuthenticated: true);
    return true;
  }
}
