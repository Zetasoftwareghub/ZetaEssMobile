import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../repository/auth_repository.dart';

final authControllerProvider = NotifierProvider<AuthController, bool>(
  () => AuthController(),
);

final isUserExistProvider = StateProvider<bool>((ref) => false);
final userIdProvider = StateProvider<String>((ref) => '');

final companyListProvider =
    FutureProvider.family<List<CompanyModel>, BuildContext>((
      ref,
      context,
    ) async {
      return ref.read(authControllerProvider.notifier).getCompanies(context);
    });

class AuthController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> forgotPassword({
    required BuildContext context,
    required String userId,
  }) async {
    state = true;
    final res = await ref
        .read(authRepositoryProvider)
        .forgotPassword(
          userContext: ref.watch(userContextProvider),
          userId: userId,
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

  Future<void> activateUrl({
    required String url,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref.read(authRepositoryProvider).activateUrl(url: url);

    state = false;
    res.fold(
      (l) {
        showSnackBar(
          content: l.errMsg,
          context: context,
          color: AppTheme.errorColor,
        );
      },
      (activateResponse) async {
        if (activateResponse != null) {
          ref.read(baseUrlProvider.notifier).state = url;
          if (activateResponse["data"] != "Authorized") {
            showSnackBar(
              content: "unauthorized".tr(),
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
          NavigationService.navigateRemoveUntil(
            context: context,
            screen: const LoginScreen(),
          );
          await ref
              .read(storageRepositoryProvider.notifier)
              .writeValue(key: StorageKeys.baseUrl, value: url);
        }
      },
    );
  }

  Future<List<CompanyModel>> getCompanies(BuildContext context) async {
    final res = await ref
        .read(authRepositoryProvider)
        .getCompanies(userContext: ref.read(userContextProvider));

    return res.fold(
      (l) {
        NavigationService.navigateRemoveUntil(
          context: context,
          screen: ActivationUrlScreen(),
        );
        throw Exception(l.errMsg);
      },
      (companies) async {
        if (companies.length == 1) {
          ref.read(userCompanyProvider.notifier).state = companies.first;

          SecureStorageService.write(
            key: StorageKeys.userCompanyModel,
            value: jsonEncode(companies.first.toJson()),
          );
        }
        return companies;
      },
    );
  }

  Future<void> loginUser({
    required String userName,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(authRepositoryProvider)
        .loginUser(
          userContext: ref.watch(userContextProvider),
          userName: userName,
          fcmToken: ref.watch(fcmTokenProvider) ?? "noToken",
          password: password,
          context: context,
        );
    state = false;
    return res.fold(
      (l) =>
          l.errMsg != '-1' &&
                  l.errMsg != '-2' &&
                  l.errMsg != '-3' &&
                  l.errMsg != '-4'
              ? showSnackBar(
                context: context,
                content: l.errMsg,
                color: AppTheme.errorColor,
              )
              : null,
      (userData) async {
        // TODO get the JWT token to local storage !
        ref.read(userDataProvider.notifier).state = userData;

        NavigationService.navigateRemoveUntil(
          context: context,
          screen: const CreatePinScreen(),
        );

        final userModel = jsonEncode(userData.toJson());
        await SecureStorageService.write(
          key: StorageKeys.userModel,
          value: userModel,
        );
      },
    );
  }

  Future<void> ssoLogin({
    required String email,
    required BuildContext context,
  }) async {
    state = true;
    final res = await ref
        .read(authRepositoryProvider)
        .ssoLogin(
          userContext: ref.watch(userContextProvider),
          email: email,
          context: context,
        );
    state = false;
    return res.fold((l) => null, (userData) async {
      ref.read(userDataProvider.notifier).state = userData;

      NavigationService.navigateRemoveUntil(
        context: context,
        screen: const CreatePinScreen(),
      );
      final userModel = jsonEncode(userData.toJson());
      await SecureStorageService.write(
        key: StorageKeys.userModel,
        value: userModel,
      );
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //TODO need to work on these both SSO and make that perfectly working
  //TODO microsoft from backend ! 🔒 Why You Can’t (Shouldn’t) Do Microsoft Sign-In Fully in Flutter Frontend
  // 🔴 Problem 1: Firebase custom tokens must be created server-side
  // Firebase only allows creating custom tokens using admin SDKs, which:
  //
  // Require a private service account key
  //
  // Cannot be exposed to the client (too sensitive)
  //
  // ✅ Only Firebase Admin SDK (Node.js, .NET, Java, etc.) can create custom tokens.

  Future<bool> loginWithMicrosoft({required BuildContext context}) async {
    try {
      state = true;
      // Create Microsoft providers
      MicrosoftAuthProvider microsoftProvider = MicrosoftAuthProvider();
      //
      // microsoftProvider.addScope('email');
      // microsoftProvider.addScope('profile');
      // microsoftProvider.addScope('openid');
      //
      // microsoftProvider.setCustomParameters({
      //   'prompt': 'select_account',
      //   'domain_hint':
      //       'consumers', // Use 'organizations' for work accounts only
      // });

      UserCredential userCredential = await _auth.signInWithProvider(
        microsoftProvider,
      );

      state = false;

      User? user = userCredential.user;

      if (user != null && user.email != null) {
        await ssoLogin(email: user.email!, context: context);
      }
    } on FirebaseAuthException catch (e) {
      state = false;

      String errorMessage = e.message ?? "";
      snack(errorMessage, context);
      return false;
    } catch (e) {
      state = false;
      return false;
    }

    return false;
  }

  snack(c, context) {
    showSnackBar(content: c, context: context);
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  Future<void> loginWithGoogle({required BuildContext context}) async {
    try {
      state = true;
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      state = false;

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null && user.email != null) {
        print(user.email!);
        print("user.email");
        await ssoLogin(email: user.email!, context: context);
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      showSnackBar(context: context, content: 'Google Sign-In failed: $e');
    }
  }
}
