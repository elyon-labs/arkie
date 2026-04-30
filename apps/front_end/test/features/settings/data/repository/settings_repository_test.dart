import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_rx_shared_preferences.dart';

void main() {
  group('SettingsRepository', () {
    group('setPrivacyMode', () {
      test('stores the privacy mode flag', () async {
        final prefs = FakeRxSharedPreferences();
        final repository = SettingsRepository(prefs: prefs);

        await repository.setPrivacyMode(true);

        expect(await prefs.read<bool>(kPrivacyModeKey, (value) => value as bool?), isTrue);

        await repository.setPrivacyMode(false);

        expect(await prefs.read<bool>(kPrivacyModeKey, (value) => value as bool?), isFalse);
      });
    });

    group('watchIsPrivacyModeEnabled', () {
      test('emits false when unset and updates with changes', () async {
        final prefs = FakeRxSharedPreferences();
        final repository = SettingsRepository(prefs: prefs);

        final valuesFuture = repository.watchIsPrivacyModeEnabled().take(2).toList();

        await repository.setPrivacyMode(true);

        final values = await valuesFuture;
        expect(values.first, isFalse); // default when unset
        expect(values.last, isTrue);
      });

      test('emits stored value when already set', () async {
        final prefs = FakeRxSharedPreferences(initialValues: {kPrivacyModeKey: true});
        final repository = SettingsRepository(prefs: prefs);

        final first = await repository.watchIsPrivacyModeEnabled().first;

        expect(first, isTrue);
      });
    });

    group('selectServer', () {
      test('stores the selected server id', () async {
        const serverId = 'server-123';
        final prefs = FakeRxSharedPreferences();
        final repository = SettingsRepository(prefs: prefs);

        await repository.selectServer(serverId);

        expect(await prefs.read<String>(kSelectedServerKey, (value) => value as String?), serverId);
      });
    });

    group('clearSelectedServer', () {
      test('removes the stored server id', () async {
        const serverId = 'server-123';
        final prefs = FakeRxSharedPreferences(initialValues: {kSelectedServerKey: serverId});
        final repository = SettingsRepository(prefs: prefs);

        await repository.clearSelectedServer();

        expect(await prefs.read<String>(kSelectedServerKey, (value) => value as String?), isNull);
      });
    });

    group('watchSelectedServer', () {
      test('emits null when no server is selected and updates when set', () async {
        const serverId = 'server-123';
        final prefs = FakeRxSharedPreferences();
        final repository = SettingsRepository(prefs: prefs);

        final valuesFuture = repository.watchSelectedServer().take(2).toList();

        await repository.selectServer(serverId);

        final values = await valuesFuture;
        expect(values.first, isNull);
        expect(values.last, serverId);
      });

      test('emits stored value when already selected', () async {
        const serverId = 'server-123';
        final prefs = FakeRxSharedPreferences(initialValues: {kSelectedServerKey: serverId});
        final repository = SettingsRepository(prefs: prefs);

        final selected = await repository.watchSelectedServer().first;

        expect(selected, serverId);
      });
    });
  });
}
