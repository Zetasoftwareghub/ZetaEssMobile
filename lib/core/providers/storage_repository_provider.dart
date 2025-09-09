import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/models/company_model.dart';
import 'package:zeta_ess/models/user_model.dart';

import '../../services/secure_stroage_service.dart';
import '../api_constants/keys/storage_keys.dart';

final jwtTokenProvider = StateProvider<String?>((ref) => null);
final baseUrlProvider = StateProvider<String?>((ref) => null);
final userDataProvider = StateProvider<UserModel?>((ref) => null);
final fcmTokenProvider = StateProvider<String?>((ref) => null);
final userCompanyProvider = StateProvider<CompanyModel?>((ref) => null);

final storageRepositoryProvider =
    NotifierProvider<StorageRepositoryProvider, String?>(() {
      return StorageRepositoryProvider();
    });

class StorageRepositoryProvider extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  loadLocalStorageValues() async {
    final fcmToken = await SecureStorageService.read(key: StorageKeys.fcmKey);
    ref.read(fcmTokenProvider.notifier).state = fcmToken;

    final userJson = await SecureStorageService.read(
      key: StorageKeys.userModel,
    );

    if (userJson != null && userJson.isNotEmpty) {
      final userMap = jsonDecode(userJson);
      final user = UserModel.fromJson(userMap);
      ref.read(userDataProvider.notifier).state = user;
    }

    final userCompanyJson = await SecureStorageService.read(
      key: StorageKeys.userCompanyModel,
    );

    if (userCompanyJson != null && userCompanyJson.isNotEmpty) {
      final companyMap = jsonDecode(userCompanyJson);
      final company = CompanyModel.fromJson(companyMap);
      ref.read(userCompanyProvider.notifier).state = company;
    }
  }

  loadValue(String key) async =>
      state = await SecureStorageService.read(key: key);

  writeValue({required String key, required String value}) async =>
      await SecureStorageService.write(key: key, value: value);

  Future<void> updateValue({
    required String value,
    required String key,
  }) async => await SecureStorageService.write(key: key, value: value);
}
