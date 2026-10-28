import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArkieTheme', () {
    for (final (name, theme) in [
      ('desktopDark', ArkieTheme.desktopDark),
      ('desktopLight', ArkieTheme.desktopLight),
      ('mobile', ArkieTheme.mobile),
    ]) {
      test('$name derives its Material color scheme from its colors', () {
        final scheme = theme.colorScheme;

        expect(scheme.brightness, theme.brightness);
        expect(scheme.primary, theme.colors.primary);
        expect(scheme.surface, theme.colors.body);
        expect(scheme.onSurface, theme.colors.foreground);
        expect(scheme.surfaceContainer, theme.colors.card);
        expect(scheme.error, theme.colors.error);
      });
    }

    testWidgets('desktop themes register the shared theme extensions', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDesktopTheme(ArkieTheme.desktopDark),
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(context.colors.body, ArkieTheme.desktopDark.colors.body);
      expect(context.text.body.fontFamily, ArkieTheme.spaceMono);
      expect(context.icons.server, ArkieTheme.desktopDark.icons.server);
    });

    testWidgets('the mobile theme registers the shared theme extensions', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMobileTheme(),
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(Theme.of(context).scaffoldBackgroundColor, ArkieTheme.mobile.colors.body);
      expect(context.colors.accent, ArkieTheme.mobile.colors.accent);
      expect(context.icons.back, ArkieTheme.mobile.icons.back);
    });
  });
}
