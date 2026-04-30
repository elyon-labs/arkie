import 'package:cs2_rcon_front_end/app/domain/set_theme_mode.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_rx_shared_preferences.dart';

void main() {
  group('SetThemeMode', () {
    test('stores the theme mode in preferences', () async {
      final prefs = FakeRxSharedPreferences();
      final repository = SettingsRepository(prefs: prefs);
      final setThemeMode = SetThemeMode(settingsRepository: repository);

      await setThemeMode(ThemeMode.light);

      expect(
        await prefs.read<String>(kThemeModeKey, (value) => value as String?),
        ThemeMode.light.name,
      );

      await setThemeMode(ThemeMode.dark);

      expect(
        await prefs.read<String>(kThemeModeKey, (value) => value as String?),
        ThemeMode.dark.name,
      );
    });
  });
}
