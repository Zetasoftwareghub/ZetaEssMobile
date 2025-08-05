// lib/providers/locale_provider.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zeta_ess/core/api_constants/keys/storage_keys.dart';

final localeLanguageProvider =
    NotifierProvider<LocaleLanguageNotifier, Locale?>(
      () => LocaleLanguageNotifier(),
    );

class LocaleLanguageNotifier extends Notifier<Locale?> {
  final _storage = const FlutterSecureStorage();
  static const _key = StorageKeys.appLanguage;

  @override
  Locale? build() {
    _loadLocale();
    return null;
  }

  Future<void> _loadLocale() async {
    final code = await _storage.read(key: _key);
    if (code != null) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _storage.write(key: _key, value: locale.languageCode);
  }
}
