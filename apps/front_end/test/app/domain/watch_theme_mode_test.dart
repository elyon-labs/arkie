import 'package:cs2_rcon_front_end/app/domain/watch_theme_mode.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_rx_shared_preferences.dart';

void main() {
  group('WatchThemeMode', () {
    test('emits system when theme mode has not been set', () async {
      final prefs = FakeRxSharedPreferences();
      final repository = SettingsRepository(prefs: prefs);
      final watchThemeMode = WatchThemeMode(settingsRepository: repository);

      final themeMode = await watchThemeMode().first;

      expect(themeMode, ThemeMode.system);
    });

    test('emits stored value and updates when changed', () async {
      final prefs = FakeRxSharedPreferences(initialValues: {kThemeModeKey: ThemeMode.dark.name});
      final repository = SettingsRepository(prefs: prefs);
      final watchThemeMode = WatchThemeMode(settingsRepository: repository);

      final valuesFuture = watchThemeMode().take(2).toList();

      await repository.setThemeMode(ThemeMode.light);

      final values = await valuesFuture;
      expect(values.first, ThemeMode.dark);
      expect(values.last, ThemeMode.light);
    });
  });
}
