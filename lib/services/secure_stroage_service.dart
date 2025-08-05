import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zeta_ess/core/api_constants/keys/storage_keys.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();

  static Future<void> write({
    required String key,
    required String value,
  }) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAll() async {
    final allKeys = await _storage.readAll();

    for (final key in allKeys.keys) {
      if (key != StorageKeys.baseUrl && key != StorageKeys.hasShownShowcase) {
        await _storage.delete(key: key);
      }
    }
  }
}
