import 'package:cs2_rcon_front_end/app/domain/set_privacy_mode_enabled.dart';
import 'package:cs2_rcon_front_end/app/domain/set_theme_mode.dart';
import 'package:cs2_rcon_front_end/app/domain/watch_is_privacy_mode_enabled.dart';
import 'package:cs2_rcon_front_end/app/domain/watch_theme_mode.dart';
import 'package:cs2_rcon_front_end/app/presentation/app_cubit.dart';
import 'package:cs2_rcon_front_end/app/presentation/widgets/sensitive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_settings_repository.dart';

void main() {
  group('SensitiveText', () {
    AppCubit buildCubit(FakeSettingsRepository settingsRepository) {
      return AppCubit(
        watchIsPrivacyModeEnabled: WatchIsPrivacyModeEnabled(
          settingsRepository: settingsRepository,
        ),
        setPrivacyModeEnabled: SetPrivacyModeEnabled(settingsRepository: settingsRepository),
        setThemeMode: SetThemeMode(settingsRepository: settingsRepository),
        watchThemeMode: WatchThemeMode(settingsRepository: settingsRepository),
      );
    }

    Widget buildApp({required AppCubit cubit, required Widget child}) {
      return BlocProvider<AppCubit>.value(
        value: cubit,
        child: MaterialApp(home: child),
      );
    }

    group('.ipAddress', () {
      testWidgets('renders child when privacy mode is disabled', (tester) async {
        final settingsRepository = FakeSettingsRepository(privacyMode: false);
        final cubit = buildCubit(settingsRepository);

        addTearDown(() async {
          await cubit.close();
          await settingsRepository.dispose();
        });

        await tester.pumpWidget(
          buildApp(
            cubit: cubit,
            child: SensitiveText.ipAddress(child: const Text('1.2.3.4')),
          ),
        );
        await tester.pump();

        expect(find.text('1.2.3.4'), findsOneWidget);
        expect(find.text('●●●.●●●.●●●.●●●'), findsNothing);
      });

      testWidgets('masks IP when privacy mode is enabled', (tester) async {
        final settingsRepository = FakeSettingsRepository(privacyMode: true);
        final cubit = buildCubit(settingsRepository);

        addTearDown(() async {
          await cubit.close();
          await settingsRepository.dispose();
        });

        await tester.pumpWidget(
          buildApp(
            cubit: cubit,
            child: SensitiveText.ipAddress(child: const Text('1.2.3.4')),
          ),
        );
        await tester.pump();

        expect(find.text('●●●.●●●.●●●.●●●'), findsOneWidget);
        expect(find.text('1.2.3.4'), findsNothing);

        await cubit.setPrivacyModeEnabled(false);
        await tester.pumpAndSettle();

        expect(find.text('1.2.3.4'), findsOneWidget);
      });
    });
  });
}
