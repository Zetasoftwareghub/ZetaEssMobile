import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zeta_ess/core/api_constants/keys/storage_keys.dart';
import 'package:zeta_ess/core/providers/storage_repository_provider.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/auth/screens/activationUrl_screen.dart';
import 'package:zeta_ess/services/secure_stroage_service.dart';

import '../../../core/common/alert_dialog/alertBox_function.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils.dart';
import '../../common/screens/main_screen.dart';
import '../repository/auth_repository.dart';

final localAuthProvider = NotifierProvider<LocalAuthNotifier, LocalAuthState>(
  () => LocalAuthNotifier(),
);

class LocalAuthState {
  final bool hasPin;
  final String? savedPin;
  final bool isAuthenticated;
  final bool urlExist;

  LocalAuthState({
    this.hasPin = false,
    this.savedPin,
    this.isAuthenticated = false,
    this.urlExist = false,
  });

  LocalAuthState copyWith({
    bool? hasPin,
    bool? isAuthenticated,
    bool? urlExist,
    String? savedPin,
  }) {
    return LocalAuthState(
      hasPin: hasPin ?? this.hasPin,
      urlExist: urlExist ?? this.urlExist,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      savedPin: savedPin ?? this.savedPin,
    );
  }
}

class LocalAuthNotifier extends Notifier<LocalAuthState> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  LocalAuthState build() {
    loadInitialAuthState();
    return LocalAuthState();
  }

  Future<void> loadInitialAuthState() async {
    // final jwtToken = await SecureStorageService.read(
    //   key: StorageKeys.jwtToken,
    // );
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

  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    final canUseBiometrics = await auth.canCheckBiometrics;
    final isDeviceSupported = await auth.isDeviceSupported();

    final isActivated = await _checkActivationAndNavigateIfNeeded(context);
    if (!isActivated) return false;

    if (!canUseBiometrics || !isDeviceSupported) return false;

    final authenticated = await auth.authenticate(
      localizedReason: 'ZETA HRMS Biometric Auth',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    if (authenticated) {
      NavigationService.navigateRemoveUntil(
        context: context,
        screen: MainScreen(),
      );
      showSnackBar(
        context: context,
        content: "Welcome to user dashboard",
        color: AppTheme.successColor,
      );

      await SecureStorageService.write(
        key: StorageKeys.biometricKey,
        value: 'true',
      );
      state = state.copyWith(isAuthenticated: true);
    }

    return authenticated;
  }

  Future<bool> _checkActivationAndNavigateIfNeeded(BuildContext context) async {
    final url = await SecureStorageService.read(key: StorageKeys.baseUrl);
    final res = await ref
        .read(authRepositoryProvider)
        .activateUrl(url: url ?? '');

    bool isAuthorized = false;

    res.fold(
      (failure) {
        //TODO check what to do here
      },
      (activateResponse) {
        if (activateResponse["data"] != "Authorized") {
          NavigationService.navigateRemoveUntil(
            context: context,
            screen: ActivationUrlScreen(),
          );
        } else {
          isAuthorized = true;
        }
      },
    );

    return isAuthorized;
  }
}
