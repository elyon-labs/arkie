import 'package:cs2_rcon_front_end/app/domain/watch_is_privacy_mode_enabled.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_rx_shared_preferences.dart';

void main() {
  group('WatchIsPrivacyModeEnabled', () {
    test('emits false when privacy mode has not been set', () async {
      final prefs = FakeRxSharedPreferences();
      final repository = SettingsRepository(prefs: prefs);
      final watchIsPrivacyModeEnabled = WatchIsPrivacyModeEnabled(settingsRepository: repository);

      final isEnabled = await watchIsPrivacyModeEnabled().first;

      expect(isEnabled, isFalse);
    });

    test('emits stored value and updates when changed', () async {
      final prefs = FakeRxSharedPreferences(initialValues: {kPrivacyModeKey: true});
      final repository = SettingsRepository(prefs: prefs);
      final watchIsPrivacyModeEnabled = WatchIsPrivacyModeEnabled(settingsRepository: repository);

      final valuesFuture = watchIsPrivacyModeEnabled().take(2).toList();

      await repository.setPrivacyMode(false);

      final values = await valuesFuture;
      expect(values.first, isTrue);
      expect(values.last, isFalse);
    });
  });
}
