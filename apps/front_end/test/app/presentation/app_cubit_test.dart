import 'package:cs2_rcon_front_end/app/domain/set_privacy_mode_enabled.dart';
import 'package:cs2_rcon_front_end/app/domain/set_theme_mode.dart';
import 'package:cs2_rcon_front_end/app/domain/watch_is_privacy_mode_enabled.dart';
import 'package:cs2_rcon_front_end/app/domain/watch_theme_mode.dart';
import 'package:cs2_rcon_front_end/app/presentation/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_settings_repository.dart';

void main() {
  group('AppCubit', () {
    group('constructor', () {
      test('emits privacy mode updates from watcher', () async {
        final settingsRepository = FakeSettingsRepository(privacyMode: false);
        final cubit = AppCubit(
          watchIsPrivacyModeEnabled: WatchIsPrivacyModeEnabled(
            settingsRepository: settingsRepository,
          ),
          setPrivacyModeEnabled: SetPrivacyModeEnabled(settingsRepository: settingsRepository),
          setThemeMode: SetThemeMode(settingsRepository: settingsRepository),
          watchThemeMode: WatchThemeMode(settingsRepository: settingsRepository),
        );

        expect(cubit.state.isPrivacyModeEnabled, isFalse);

        await settingsRepository.setPrivacyMode(true);
        await pumpEventQueue();

        expect(cubit.state.isPrivacyModeEnabled, isTrue);

        await cubit.close();
        await settingsRepository.dispose();
      });
    });

    group('setPrivacyModeEnabled', () {
      test('delegates to SetPrivacyModeEnabled', () async {
        final settingsRepository = FakeSettingsRepository(privacyMode: false);
        final cubit = AppCubit(
          watchIsPrivacyModeEnabled: WatchIsPrivacyModeEnabled(
            settingsRepository: settingsRepository,
          ),
          setPrivacyModeEnabled: SetPrivacyModeEnabled(settingsRepository: settingsRepository),
          setThemeMode: SetThemeMode(settingsRepository: settingsRepository),
          watchThemeMode: WatchThemeMode(settingsRepository: settingsRepository),
        );

        final valuesFuture = settingsRepository.watchIsPrivacyModeEnabled().take(2).toList();

        await cubit.setPrivacyModeEnabled(true);

        final values = await valuesFuture;
        expect(values.first, isFalse);
        expect(values.last, isTrue);

        await cubit.close();
        await settingsRepository.dispose();
      });
    });

    group('togglePrivacyModeEnabled', () {
      test('toggles the current privacy mode state', () async {
        final settingsRepository = FakeSettingsRepository(privacyMode: false);
        final cubit = AppCubit(
          watchIsPrivacyModeEnabled: WatchIsPrivacyModeEnabled(
            settingsRepository: settingsRepository,
          ),
          setPrivacyModeEnabled: SetPrivacyModeEnabled(settingsRepository: settingsRepository),
          setThemeMode: SetThemeMode(settingsRepository: settingsRepository),
          watchThemeMode: WatchThemeMode(settingsRepository: settingsRepository),
        );

        final valuesFuture = settingsRepository.watchIsPrivacyModeEnabled().take(3).toList();

        await cubit.togglePrivacyModeEnabled(); // false -> true
        await cubit.togglePrivacyModeEnabled(); // true -> false

        final values = await valuesFuture;
        expect(values, [false, true, false]);

        await cubit.close();
        await settingsRepository.dispose();
      });
    });

    group('setThemeMode', () {
      test('delegates to SetThemeMode', () async {
        final settingsRepository = FakeSettingsRepository();
        final cubit = AppCubit(
          watchIsPrivacyModeEnabled: WatchIsPrivacyModeEnabled(
            settingsRepository: settingsRepository,
          ),
          setPrivacyModeEnabled: SetPrivacyModeEnabled(settingsRepository: settingsRepository),
          setThemeMode: SetThemeMode(settingsRepository: settingsRepository),
          watchThemeMode: WatchThemeMode(settingsRepository: settingsRepository),
        );

        final valuesFuture = settingsRepository.watchThemeMode().take(2).toList();

        await cubit.setThemeMode(ThemeMode.dark);

        final values = await valuesFuture;
        expect(values, [ThemeMode.system, ThemeMode.dark]);

        await cubit.close();
        await settingsRepository.dispose();
      });
    });
  });
}
