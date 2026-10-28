import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArkieTheme', () {
    for (final (name, theme) in [('desktop', ArkieTheme.desktop), ('mobile', ArkieTheme.mobile)]) {
      test('$name derives its Material color scheme from its colors', () {
        final scheme = theme.colorScheme;

        expect(scheme.brightness, theme.brightness);
        expect(scheme.primary, theme.colors.primary);
        expect(scheme.surface, theme.colors.body);
        expect(scheme.onSurface, theme.colors.foreground);
        expect(scheme.surfaceContainer, theme.colors.card);
        expect(scheme.error, theme.colors.error);
        expect(scheme.outline, theme.arkieColors.border);
      });

      test('$name is dark and set in Space Mono', () {
        expect(theme.brightness, Brightness.dark);
        expect(theme.fontFamily, ArkieTheme.spaceMono);
      });
    }

    testWidgets('the desktop theme registers the shared theme extensions', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDesktopTheme(),
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(context.colors.body, ArkieTheme.desktop.colors.body);
      expect(context.arkieColors.border, ArkieTheme.desktop.arkieColors.border);
      expect(context.text.body.fontFamily, ArkieTheme.spaceMono);
      expect(context.icons.server, ArkieTheme.desktop.icons.server);
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
      expect(context.arkieColors.textFaint, ArkieTheme.mobile.arkieColors.textFaint);
      expect(context.text.body.fontFamily, ArkieTheme.spaceMono);
      expect(context.icons.back, ArkieTheme.mobile.icons.back);
    });
  });

  group('TerminalPanel', () {
    testWidgets('notches its label and trailing widget into the border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDesktopTheme(),
          home: const Scaffold(
            body: TerminalPanel(
              label: 'server',
              trailing: StatusLamp(state: LinkState.live),
              child: Text('10.0.0.4'),
            ),
          ),
        ),
      );

      expect(find.text('server'), findsOneWidget);
      expect(find.text('live'), findsOneWidget);
      expect(find.text('10.0.0.4'), findsOneWidget);
    });
  });

  group('ConsoleLine', () {
    testWidgets('gives commands the prompt sigil and the accent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMobileTheme(),
          home: const Scaffold(body: ConsoleLine(text: 'sv_cheats 1', isInput: true)),
        ),
      );

      expect(find.text('>'), findsOneWidget);
      final body = tester.widget<Text>(find.text('sv_cheats 1'));
      expect(body.style?.color, ArkieTheme.mobile.colors.accent);
    });

    testWidgets('leaves server output plain, in the sigil column', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMobileTheme(),
          home: const Scaffold(body: ConsoleLine(text: 'hostname: Larry', isInput: false)),
        ),
      );

      expect(find.text('>'), findsNothing);
      final body = tester.widget<Text>(find.text('hostname: Larry'));
      expect(body.style?.color, ArkieTheme.mobile.colors.foreground);
    });
  });
}
