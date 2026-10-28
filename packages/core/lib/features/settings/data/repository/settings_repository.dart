import 'package:flutter/material.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class SettingsRepository {
  SettingsRepository({required RxSharedPreferences prefs}) : _prefs = prefs;

  final RxSharedPreferences _prefs;

  Future<void> setPrivacyMode(bool isEnabled) async {
    await _prefs.setBool(kPrivacyModeKey, isEnabled);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(kThemeModeKey, mode.name);
  }

  Stream<bool> watchIsPrivacyModeEnabled() {
    return _prefs.getBoolStream(kPrivacyModeKey).map((isEnabled) => isEnabled ?? false);
  }

  Stream<ThemeMode> watchThemeMode() {
    return _prefs.getStringStream(kThemeModeKey).map((mode) {
      if (mode == null) return ThemeMode.system;
      return ThemeMode.values.byName(mode);
    });
  }

  Future<void> selectServer(String serverId) {
    return _prefs.setString(kSelectedServerKey, serverId);
  }

  Future<void> clearSelectedServer() {
    return _prefs.remove(kSelectedServerKey);
  }

  Stream<String?> watchSelectedServer() {
    return _prefs.getStringStream(kSelectedServerKey);
  }

  Future<void> dispose() async {
    await _prefs.dispose();
  }
}

const String kPrivacyModeKey = 'privacy_mode';
const String kSelectedServerKey = 'selected_server';
const String kThemeModeKey = 'theme_mode';
