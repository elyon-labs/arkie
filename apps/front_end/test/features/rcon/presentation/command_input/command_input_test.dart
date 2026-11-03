import 'package:arkie_core/features/rcon/demo/demo_rcon_server.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_state/features/rcon/rcon_state.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/command_input/command_input.dart';
import 'package:dart_foundation/dart_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

class _MockRCONCubit extends MockCubit<RCONState> implements RCONCubit {}

void main() {
  group('CommandInput', () {
    late _MockRCONCubit cubit;

    setUp(() {
      final demo = DemoRCONServer(address: Server.demoAddress, port: Server.demoPort);
      var packetId = 1;
      final connection = RCONConnection(
        sendCommand: (command) async =>
            Ok(RCONServerPacket.responseValue(id: packetId++, body: demo.execute(command))),
        closeConnection: () async {},
      );

      cubit = _MockRCONCubit();
      whenListen(
        cubit,
        const Stream<RCONState>.empty(),
        initialState: RCONState(
          server: Server.demo(),
          messages: [],
          savedMessages: [],
          connection: Loaded(connection),
        ),
      );
    });

    Future<void> pumpInput(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildDesktopTheme(),
          home: BlocProvider<RCONCubit>.value(
            value: cubit,
            child: const Scaffold(body: Column(children: [Spacer(), CommandInput()])),
          ),
        ),
      );
    }

    Future<void> type(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      // The cubit debounces before it asks the server for matches.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
    }

    testWidgets('shows the suggestions the server matched', (tester) async {
      await pumpInput(tester);
      await type(tester, 'sv_chea');

      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.text('sv_cheats'), findsOneWidget);
    });

    testWidgets('completes the command the arrow keys highlighted', (tester) async {
      await pumpInput(tester);
      await type(tester, 'sv_chea');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, 'sv_cheats');
    });

    testWidgets('completes the command that was tapped', (tester) async {
      await pumpInput(tester);
      await type(tester, 'sv_chea');

      await tester.tap(find.text('sv_cheats'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, 'sv_cheats');
    });
  });
}
