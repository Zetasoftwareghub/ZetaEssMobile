import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zeta_ess/core/api_constants/keys/storage_keys.dart';
import 'package:zeta_ess/core/common/alert_dialog/alertBox_function.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/features/auth/screens/activationUrl_screen.dart';
import 'package:zeta_ess/features/auth/screens/createPin_screen.dart';
import 'package:zeta_ess/features/auth/screens/login_screen.dart';
import 'package:zeta_ess/models/company_model.dart';
import 'package:zeta_ess/services/secure_stroage_service.dart';

import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/services/NavigationService.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils.dart';
import '../../../services/firebase_notification.dart';
import '../../common/screens/main_screen.dart';
import '../../common/screens/notification_screen.dart';
import '../repository/auth_repository.dart';

final authControllerProvider = NotifierProvider<AuthController, bool>(
  () => AuthController(),
);

final isUserExistProvider = StateProvider<bool>((ref) => false);
final userIdProvider = StateProvider<String>((ref) => '');

final companyListProvider =
    FutureProvider.family<List<CompanyModel>, BuildContext>(
      (ref, context) async =>
          ref.read(authControllerProvider.notifier).getCompanies(context),
    );

class AuthController extends Notifier<bool> {
  @override
  bool build() => false;

  // ─────────────────────────────────────────────
  // Forgot password
  // ─────────────────────────────────────────────

  Future<void> forgotPassword({
    required BuildContext context,
    required String userId,
  }) async {
    state = true;
    final res = await ref
        .read(authRepositoryProvider)
        .forgotPassword(
          userContext: ref.read(userContextProvider),
          userId: userId,
          sucode: ref.read(userCompanyProvider)?.companyCode.toString() ?? '0',
        );
    state = false;
    res.fold(
      (l) => showSnackBar(
        content: l.errMsg,
        context: context,
        color: AppTheme.errorColor,
      ),
      (r) => showCustomAlertBox(context, title: r ?? 'Server error'),
    );
  }

  // ─────────────────────────────────────────────
  // URL activation
  // ─────────────────────────────────────────────

  Future<void> activateUrl({
    required String url,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref.read(authRepositoryProvider).activateUrl(url: url);
    state = false;

    res.fold(
      (l) => showSnackBar(
        content: l.errMsg,
        context: context,
        color: AppTheme.errorColor,
      ),
      (activateResponse) async {
        if (activateResponse == null) return;

        ref.read(baseUrlProvider.notifier).state = url;

        if (activateResponse['data'] != 'Authorized') {
          showSnackBar(
            content: 'unauthorized'.tr(),
            context: context,
            color: AppTheme.errorColor,
          );
          return;
        }

        showSnackBar(
          content: 'urlActivated'.tr(),
          context: context,
          color: AppTheme.successColor,
        );

        await ref
            .read(storageRepositoryProvider.notifier)
            .writeValue(key: StorageKeys.baseUrl, value: url);

        if (context.mounted) {
          NavigationService.navigateRemoveUntil(
            context: context,
            screen: const LoginScreen(),
          );
        }
      },
    );
  }

  // ─────────────────────────────────────────────
  // Company list
  // ─────────────────────────────────────────────

  Future<List<CompanyModel>> getCompanies(BuildContext context) async {
    final res = await ref
        .read(authRepositoryProvider)
        .getCompanies(userContext: ref.read(userContextProvider));

    return res.fold((l) => throw Exception(l.errMsg), (companies) async {
      if (companies.length == 1) {
        ref.read(userCompanyProvider.notifier).state = companies.first;
        await SecureStorageService.write(
          key: StorageKeys.userCompanyModel,
          value: jsonEncode(companies.first.toJson()),
        );
      }
      return companies;
    });
  }

  // ─────────────────────────────────────────────
  // Login
  // ─────────────────────────────────────────────

  Future<void> loginUser({
    required String userName,
    required String password,
    required BuildContext context,
    bool fromPinScreen = false,
  }) async {
    // Guard: never run if widget is gone.
    if (!context.mounted) return;

    state = true;
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final res = await ref
          .read(authRepositoryProvider)
          .loginUser(
            userContext: ref.read(userContextProvider),
            userName: userName,
            fcmToken: fcmToken ?? 'noToken',
            password: password,
            context: context,
            fromPinScreen: fromPinScreen,
          );

      // ✅ state = false lives only in finally — no duplicate assignments.
      return res.fold(
        (l) {
          if (!context.mounted) return;

          // -1 / -2 / -3 are internal codes the server uses for silent flows.
          final silentCodes = {'-1', '-2', '-3'};
          if (!silentCodes.contains(l.errMsg)) {
            showSnackBar(
              context: context,
              content:
                  l.errMsg == '-4'
                      ? 'Your license has expired. Please contact your administrator'
                      : l.errMsg,
              color: AppTheme.errorColor,
            );
          }
        },
        (userData) async {
          if (!context.mounted) return;

          // Persist user data in memory and secure storage.
          final enrichedUser = userData.copyWith(
            password: password,
            userName: userName,
          );
          ref.read(userDataProvider.notifier).state = enrichedUser;

          await SecureStorageService.write(
            key: StorageKeys.userModel,
            value: jsonEncode(enrichedUser.toJson()),
          );

          if (!context.mounted) return;

          // Navigate to the correct destination.
          if (openNotificationScreenAfterLogin) {
            openNotificationScreenAfterLogin = false;
            await NavigationService.navigateRemoveUntil(
              context: context,
              screen: MainScreen(),
            );
            // Push NotificationsScreen after MainScreen settles.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                NavigationService.navigateToScreen(
                  context: context,
                  screen: NotificationsScreen(),
                );
              }
            });
          } else {
            NavigationService.navigateRemoveUntil(
              context: context,
              screen: fromPinScreen ? MainScreen() : const CreatePinScreen(),
            );
          }
        },
      );
    } on DioException catch (dioError) {
      if (!context.mounted) return;
      showSnackBar(
        context: context,
        content: dioError.message ?? 'Network error. Please try again.',
        color: AppTheme.errorColor,
      );
    } catch (e, st) {
      debugPrint('Login failed: $e');
      debugPrintStack(stackTrace: st);
      if (!context.mounted) return;
      showSnackBar(
        context: context,
        content: 'Something went wrong. Please try again.',
        color: AppTheme.errorColor,
      );
    } finally {
      // ✅ Single, unconditional reset — no partial state left behind.
      state = false;
    }
  }

  // ─────────────────────────────────────────────
  // SSO — shared post-login logic
  // ─────────────────────────────────────────────

  Future<void> ssoLogin({
    required String email,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(authRepositoryProvider)
        .ssoLogin(
          userContext: ref.read(userContextProvider),
          email: email,
          context: context,
        );
    state = false;

    res.fold(
      (l) {
        if (!context.mounted) return;
        showSnackBar(
          context: context,
          content: 'Please verify your email with HR',
          color: AppTheme.errorColor,
        );
      },
      (userData) async {
        ref.read(userDataProvider.notifier).state = userData;
        await SecureStorageService.write(
          key: StorageKeys.userModel,
          value: jsonEncode(userData.toJson()),
        );
        if (!context.mounted) return;
        NavigationService.navigateRemoveUntil(
          context: context,
          screen: const CreatePinScreen(),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Microsoft SSO
  // ─────────────────────────────────────────────

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> loginWithMicrosoft({required BuildContext context}) async {
    try {
      state = true;
      final userCredential = await _auth.signInWithProvider(
        MicrosoftAuthProvider(),
      );
      state = false;

      final user = userCredential.user;
      if (user?.email != null && context.mounted) {
        await ssoLogin(email: user!.email!, context: context);
      }
    } on FirebaseAuthException catch (e) {
      state = false;
      if (context.mounted) {
        showSnackBar(content: e.message ?? '', context: context);
      }
      return false;
    } catch (_) {
      state = false;
      return false;
    }
    return false;
  }

  // ─────────────────────────────────────────────
  // Google SSO
  // ─────────────────────────────────────────────

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> loginWithGoogle({required BuildContext context}) async {
    try {
      state = true;
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = false;
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      state = false;

      final user = userCredential.user;
      if (user?.email != null && context.mounted) {
        await ssoLogin(email: user!.email!, context: context);
      }
    } catch (e, st) {
      state = false;
      debugPrint('Google Sign-In error: $e');
      debugPrintStack(stackTrace: st);
      if (!context.mounted) return;
      showSnackBar(
        context: context,
        content: 'Google Sign-In failed',
        color: AppTheme.errorColor,
      );
    }
  }
}
