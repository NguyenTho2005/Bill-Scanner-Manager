import 'dart:convert';

import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists assistant configuration, including the optional API key.
abstract class AssistantSettingsStore {
  /// Loads the current configuration (defaults to offline-only).
  Future<AssistantSettings> load();

  /// Saves [settings] to secure storage.
  Future<void> save(AssistantSettings settings);
}

/// [AssistantSettingsStore] backed by `flutter_secure_storage`.
///
/// The API key never touches SQLite or logs, mirroring the app's PIN handling.
class SecureAssistantSettingsStore implements AssistantSettingsStore {
  /// Creates the store.
  SecureAssistantSettingsStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const _key = 'assistant_settings_v1';

  @override
  Future<AssistantSettings> load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return const AssistantSettings();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const AssistantSettings();
      return AssistantSettings.fromJson(decoded);
    } on Object {
      return const AssistantSettings();
    }
  }

  @override
  Future<void> save(AssistantSettings settings) async {
    await _storage.write(key: _key, value: jsonEncode(settings.toJson()));
  }
}
