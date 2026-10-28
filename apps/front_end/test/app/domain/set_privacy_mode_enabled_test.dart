import 'package:arkie_core/features/settings/data/repository/settings_repository.dart';
import 'package:arkie_core/testing/fake_rx_shared_preferences.dart';
import 'package:cs2_rcon_front_end/app/domain/set_privacy_mode_enabled.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SetPrivacyModeEnabled', () {
    test('stores the privacy mode flag in preferences', () async {
      final prefs = FakeRxSharedPreferences();
      final repository = SettingsRepository(prefs: prefs);
      final setPrivacyModeEnabled = SetPrivacyModeEnabled(settingsRepository: repository);

      await setPrivacyModeEnabled(true);

      expect(await prefs.read<bool>(kPrivacyModeKey, (value) => value as bool?), isTrue);

      await setPrivacyModeEnabled(false);

      expect(await prefs.read<bool>(kPrivacyModeKey, (value) => value as bool?), isFalse);
    });
  });
}
