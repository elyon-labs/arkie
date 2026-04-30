import 'package:bloc_test/bloc_test.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart' hide SendCommand;
import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/messages_repository.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/clear_messages.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/connect.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/drop_connection.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/get_socket.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/rename_saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/save_connection.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/save_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/send_command.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/unsave_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/watch_saved_messages.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/watch_server_messages.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_state.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/remove_server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/watch_selected_server.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';
import 'package:uuid/uuid.dart';

import '../../../fakes/fake_environment.dart';
import '../../../fakes/fake_get_socket.dart';
import '../../../fakes/fake_messages_api.dart';
import '../../../fakes/fake_rcon_connection.dart';
import '../../../fakes/fake_saved_messages_api.dart';
import '../../../fakes/fake_servers_api.dart';
import '../../../fakes/fake_settings_repository.dart';

void main() {
  group('RCONCubit', () {
    Server buildServer({
      String name = 'Test Server',
      String address = '127.0.0.1',
      int port = 27015,
      String password = 'password',
    }) {
      return Server.create(name: name, password: password, address: address, port: port);
    }

    RCONServerPacket buildPacket({
      int id = 1,
      ServerPacketType type = ServerPacketType.SERVERDATA_RESPONSE_VALUE,
      String body = 'test response',
    }) {
      return RCONServerPacket.raw(id: id, type: type, body: body);
    }

    Message buildMessage({
      required Server server,
      String body = 'message',
      Sender sender = Sender.server,
    }) {
      return Message.create(body: body, sender: sender, serverId: server.id);
    }

    SavedMessage buildSavedMessage({
      required Server server,
      String name = 'saved',
      String body = 'body',
    }) {
      return SavedMessage(id: const Uuid().v4(), serverId: server.id, body: body, name: name);
    }

    RCONCubit buildSubject({
      required Server server,
      Connect? connect,
      SendCommand? sendCommand,
      SaveMessage? saveMessage,
      UnsaveMessage? unsaveMessage,
      RenameSavedMessage? renameSavedMessage,
      MessagesRepository? messagesRepository,
      SavedMessagesRepository? savedMessagesRepository,
      SettingsRepository? settingsRepository,
      ServersRepository? serversRepository,
      ConnectionCache? connectionCache,
      Duration? connectionCheckInterval,
    }) {
      messagesRepository ??= MessagesRepository(server: server, api: FakeMessagesApi());
      savedMessagesRepository ??= SavedMessagesRepository(
        server: server,
        api: FakeSavedMessagesApi(),
      );
      settingsRepository ??= FakeSettingsRepository();
      serversRepository ??= ServersRepository(api: FakeServersApi());
      connectionCache ??= ConnectionCache();
      return RCONCubit(
        server: server,
        connectionCheckInterval: connectionCheckInterval,
        connect:
            connect ??
            Connect(
              getSocket: GetSocket(
                connectionCache: connectionCache,
                environment: FakeEnvironment(),
              ),
              addSocket: SaveConnection(connectionCache: connectionCache),
              removeSocket: DropConnection(connectionCache: connectionCache),
            ),
        watchServerMessages: WatchServerMessages(messagesRepository: messagesRepository),
        watchedSavedMessages: WatchSavedMessages(repository: savedMessagesRepository),
        sendCommand:
            sendCommand ??
            SendCommand(
              messagesRepository: messagesRepository,
              clearMessages: ClearMessages(messagesRepository: messagesRepository),
            ),
        saveMessage: saveMessage ?? SaveMessage(savedMessagesRepository: savedMessagesRepository),
        renameSavedMessage:
            renameSavedMessage ??
            RenameSavedMessage(savedMessagesRepository: savedMessagesRepository),
        unsaveMessage:
            unsaveMessage ?? UnsaveMessage(savedMessagesRepository: savedMessagesRepository),
        removeServer: RemoveServer(
          watchSelectedServer: WatchSelectedServer(
            repository: serversRepository,
            settingsRepository: settingsRepository,
          ),
          messagesRepository: messagesRepository,
          serversRepository: serversRepository,
          settingsRepository: settingsRepository,
        ),
      );
    }

    group('initialization', () {
      blocTest<RCONCubit, RCONState>(
        'initializes with Loading connection state',
        build: () {
          final connectionCache = ConnectionCache();

          final server = buildServer();
          final messagesRepository = MessagesRepository(server: server, api: FakeMessagesApi());
          final serversRepository = ServersRepository(api: FakeServersApi());

          return buildSubject(
            server: server,
            messagesRepository: messagesRepository,
            serversRepository: serversRepository,
            connectionCache: connectionCache,
          );
        },
        skip: 0,
        verify: (cubit) {
          expect(cubit.state.connection, isA<Loading<RCONConnection>>());
          expect(cubit.state.server.name, equals('Test Server'));
          expect(cubit.state.messages, isEmpty);
          expect(cubit.state.lastConnectionCheckTime, isNull);
        },
      );

      blocTest<RCONCubit, RCONState>(
        'transitions to Loaded connection state when connection succeeds',
        build: () {
          final connectionCache = ConnectionCache();
          final server = buildServer();
          final fakeConnection = FakeRCONConnection(
            onSendCommand: (_) async => Ok(buildPacket(body: 'ping')),
          );

          return buildSubject(
            server: server,
            connect: Connect(
              getSocket: FakeGetSocket(onConnect: () => Future.value(Ok(fakeConnection))),
              addSocket: SaveConnection(connectionCache: connectionCache),
              removeSocket: DropConnection(connectionCache: connectionCache),
            ),
          );
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<RCONState>().having(
            (s) => s.connection,
            'connection',
            isA<Loading<RCONConnection>>(),
          ),
          isA<RCONState>()
              .having((s) => s.connection, 'connection', isA<Loaded<RCONConnection>>())
              .having((s) => s.lastConnectionCheckTime, 'lastConnectionCheckTime', isNotNull),
        ],
      );

      blocTest<RCONCubit, RCONState>(
        'transitions to Error connection state when connection fails',
        build: () {
          final server = buildServer();
          final connectionCache = ConnectionCache();

          return buildSubject(
            server: server,
            connect: Connect(
              getSocket: FakeGetSocket(onConnect: () async => Err(Exception('Connection failed'))),
              addSocket: SaveConnection(connectionCache: connectionCache),
              removeSocket: DropConnection(connectionCache: connectionCache),
            ),
          );
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<RCONState>().having(
            (s) => s.connection,
            'connection',
            isA<Loading<RCONConnection>>(),
          ),
          isA<RCONState>().having((s) => s.connection, 'connection', isA<Error<RCONConnection>>()),
        ],
      );
    });

    group('sendCommand', () {
      blocTest<RCONCubit, RCONState>(
        'invokes SendCommand when connection is loaded',
        build: () {
          final server = buildServer();
          final connectionCache = ConnectionCache();

          return buildSubject(
            server: server,
            connect: Connect(
              getSocket: FakeGetSocket(
                onConnect: () => Future.value(
                  Ok(
                    FakeRCONConnection(
                      onSendCommand: (command) async {
                        return Ok(buildPacket(body: 'response to: $command'));
                      },
                    ),
                  ),
                ),
              ),
              addSocket: SaveConnection(connectionCache: connectionCache),
              removeSocket: DropConnection(connectionCache: connectionCache),
            ),
          );
        },
        wait: const Duration(milliseconds: 100),
        act: (cubit) async {
          await pumpEventQueue();
          await cubit.sendCommand('ping');
        },
        verify: (cubit) async {
          expect(cubit.state.messages, isNotEmpty);
        },
      );

      blocTest<RCONCubit, RCONState>(
        'does nothing when connection is not loaded',
        build: () {
          final server = buildServer();
          final connectionCache = ConnectionCache();

          return buildSubject(
            server: server,
            connect: Connect(
              getSocket: FakeGetSocket(
                onConnect: () => Future.value(Err(Exception('Connection failed'))),
              ),
              addSocket: SaveConnection(connectionCache: connectionCache),
              removeSocket: DropConnection(connectionCache: connectionCache),
            ),
          );
        },
        wait: const Duration(milliseconds: 100),
        act: (cubit) async {
          await cubit.sendCommand('ping');
        },
        expect: () => [
          isA<RCONState>().having(
            (s) => s.connection,
            'connection',
            isA<Loading<RCONConnection>>(),
          ),
          // Only the error connection state, no messages added
          isA<RCONState>()
              .having((s) => s.connection, 'connection', isA<Error<RCONConnection>>())
              .having((s) => s.messages, 'messages', isEmpty),
        ],
      );
    });

    group('saved messages', () {
      blocTest<RCONCubit, RCONState>(
        'saveMessage adds the saved message to state',
        build: () {
          final server = buildServer();
          final savedMessagesRepository = SavedMessagesRepository(
            server: server,
            api: FakeSavedMessagesApi(),
          );

          return buildSubject(server: server, savedMessagesRepository: savedMessagesRepository);
        },
        act: (cubit) async {
          await pumpEventQueue(); // allow initial fetches
          final message = buildMessage(
            server: cubit.state.server,
            body: 'hello',
            sender: Sender.client,
          );
          await cubit.saveMessage(message);
          await pumpEventQueue();
        },
        verify: (cubit) async {
          expect(cubit.state.savedMessages, hasLength(1));
          final saved = cubit.state.savedMessages.single;
          expect(saved.body, 'hello');
          expect(saved.name, 'hello');
          expect(saved.serverId, cubit.state.server.id);
        },
      );

      blocTest<RCONCubit, RCONState>(
        'unsaveMessage removes the saved message from state',
        build: () {
          final server = buildServer();
          final initialSavedMessage = buildSavedMessage(server: server, name: 'old', body: 'old');
          final savedMessagesRepository = SavedMessagesRepository(
            server: server,
            api: FakeSavedMessagesApi(initialMessages: [initialSavedMessage]),
          );

          return buildSubject(server: server, savedMessagesRepository: savedMessagesRepository);
        },
        act: (cubit) async {
          await pumpEventQueue(); // allow initial fetches
          final savedMessage = cubit.state.savedMessages.single;
          await cubit.unsaveMessage(savedMessage);
          await pumpEventQueue();
        },
        verify: (cubit) async {
          expect(cubit.state.savedMessages, isEmpty);
        },
      );

      blocTest<RCONCubit, RCONState>(
        'renameSavedMessage updates the saved message name in state',
        build: () {
          final server = buildServer();
          final initialSavedMessage = buildSavedMessage(server: server, name: 'old', body: 'body');
          final savedMessagesRepository = SavedMessagesRepository(
            server: server,
            api: FakeSavedMessagesApi(initialMessages: [initialSavedMessage]),
          );

          return buildSubject(server: server, savedMessagesRepository: savedMessagesRepository);
        },
        act: (cubit) async {
          await pumpEventQueue(); // allow initial fetches
          final savedMessage = cubit.state.savedMessages.single;
          await cubit.renameSavedMessage(savedMessage.id, 'new');
          await pumpEventQueue();
        },
        verify: (cubit) async {
          expect(cubit.state.savedMessages.single.name, 'new');
        },
      );
    });

    group('retryConnection', () {
      blocTest<RCONCubit, RCONState>(
        'transitions through Loading to Loaded when retry succeeds',
        build: () {
          final server = buildServer();
          var isFirstCheck = true;

          final fakeConnection = FakeRCONConnection(
            onSendCommand: (command) async {
              return Ok(buildPacket(body: 'response'));
            },
          );

          return buildSubject(
            server: server,
            connect: Connect(
              getSocket: FakeGetSocket(
                onConnect: () async {
                  if (isFirstCheck) {
                    isFirstCheck = false;
                    return Err(Exception('Initial connection failed'));
                  } else {
                    return Ok(fakeConnection);
                  }
                },
              ),
              addSocket: SaveConnection(connectionCache: ConnectionCache()),
              removeSocket: DropConnection(connectionCache: ConnectionCache()),
            ),
          );
        },
        wait: const Duration(milliseconds: 300),
        act: (cubit) async {
          await pumpEventQueue();
          await cubit.retryConnection();
        },
        expect: () => [
          isA<RCONState>().having(
            (s) => s.connection,
            'connection',
            isA<Loading<RCONConnection>>(),
          ),
          // Initial error state
          isA<RCONState>().having((s) => s.connection, 'connection', isA<Error<RCONConnection>>()),
          // Loading state during retry
          isA<RCONState>().having(
            (s) => s.connection,
            'connection',
            isA<Loading<RCONConnection>>(),
          ),
          isA<RCONState>().having((s) => s.connection, 'connection', isA<Loaded<RCONConnection>>()),
        ],
      );

      blocTest<RCONCubit, RCONState>(
        'updates lastConnectionCheckTime when retry succeeds',
        build: () {
          final server = buildServer();
          final fakeConnection = FakeRCONConnection(
            onSendCommand: (command) async {
              return Ok(buildPacket(body: 'response'));
            },
          );
          final connectionCache = ConnectionCache();

          return buildSubject(
            server: server,
            connect: Connect(
              getSocket: FakeGetSocket(onConnect: () => Future.value(Ok(fakeConnection))),
              addSocket: SaveConnection(connectionCache: connectionCache),
              removeSocket: DropConnection(connectionCache: connectionCache),
            ),
          );
        },
        wait: const Duration(milliseconds: 100),
        act: (cubit) async {
          await pumpEventQueue();
          await cubit.retryConnection();
        },
        expect: () => [
          // Initial connection success with timestamp
          isA<RCONState>().having(
            (s) => s.connection,
            'connection',
            isA<Loading<RCONConnection>>(),
          ),
          isA<RCONState>()
              .having((s) => s.connection, 'connection', isA<Loaded<RCONConnection>>())
              .having((s) => s.lastConnectionCheckTime, 'lastConnectionCheckTime', isNotNull),
          // Loading during retry
          isA<RCONState>().having(
            (s) => s.connection,
            'connection',
            isA<Loading<RCONConnection>>(),
          ),
          // After retry with updated timestamp
          isA<RCONState>()
              .having((s) => s.connection, 'connection', isA<Loaded<RCONConnection>>())
              .having((s) => s.lastConnectionCheckTime, 'lastConnectionCheckTime', isNotNull),
        ],
      );
    });

    group('close', () {
      var isClosedCalled = false;

      setUp(() {
        isClosedCalled = false;
      });

      blocTest<RCONCubit, RCONState>(
        'does not close connection when in Loaded state',
        build: () {
          final server = buildServer();
          final fakeConnection = FakeRCONConnection(
            onSendCommand: (command) async {
              return Ok(buildPacket(body: 'response'));
            },
            onClose: () {
              isClosedCalled = true;
            },
          );
          final connectionCache = ConnectionCache();

          return buildSubject(
            server: server,
            connect: Connect(
              getSocket: FakeGetSocket(onConnect: () => Future.value(Ok(fakeConnection))),
              addSocket: SaveConnection(connectionCache: connectionCache),
              removeSocket: DropConnection(connectionCache: connectionCache),
            ),
          );
        },
        wait: const Duration(milliseconds: 100),
        act: (cubit) async {
          // Pump event queue to allow initial connection to complete
          await pumpEventQueue();
          await cubit.close();
          // Pump event queue to allow close to complete
          await pumpEventQueue();
        },
        verify: (cubit) async {
          expect(isClosedCalled, isFalse);
        },
      );
    });

    group('connection monitoring', () {
      var pingCount = 0;

      setUp(() {
        pingCount = 0;
      });

      blocTest<RCONCubit, RCONState>(
        'periodically checks connection health',
        build: () {
          final server = buildServer();
          final fakeConnection = FakeRCONConnection(
            onSendCommand: (command) async {
              if (command == 'echo ping') {
                pingCount++;
                return Ok(buildPacket(body: 'ping'));
              }
              return Err(Exception('Unknown command'));
            },
          );
          final connectionCache = ConnectionCache();

          return buildSubject(
            server: server,
            connectionCheckInterval: const Duration(milliseconds: 200),
            connect: Connect(
              getSocket: FakeGetSocket(onConnect: () => Future.value(Ok(fakeConnection))),
              addSocket: SaveConnection(connectionCache: connectionCache),
              removeSocket: DropConnection(connectionCache: connectionCache),
            ),
          );
        },
        wait: const Duration(seconds: 1),
        verify: (cubit) async {
          // Verify that ping command was sent multiple times
          expect(pingCount, greaterThan(1));
          await cubit.close();
        },
      );

      blocTest<RCONCubit, RCONState>(
        'updates lastConnectionCheckTime after successful health check',
        build: () {
          final server = buildServer();
          final fakeConnection = FakeRCONConnection(
            onSendCommand: (command) async {
              if (command == 'echo ping') {
                return Ok(buildPacket(body: 'ping'));
              }
              return Err(Exception('Unknown command'));
            },
          );
          final connectionCache = ConnectionCache();

          return buildSubject(
            server: server,
            connectionCheckInterval: const Duration(milliseconds: 200),
            connect: Connect(
              getSocket: FakeGetSocket(onConnect: () => Future.value(Ok(fakeConnection))),
              addSocket: SaveConnection(connectionCache: connectionCache),
              removeSocket: DropConnection(connectionCache: connectionCache),
            ),
          );
        },
        wait: const Duration(seconds: 1),
        skip: 1, // Skip initial state
        verify: (cubit) async {
          // Verify that lastConnectionCheckTime was updated
          expect(cubit.state.lastConnectionCheckTime, isNotNull);
          final timeSinceCheck = DateTime.now().difference(cubit.state.lastConnectionCheckTime!);
          expect(timeSinceCheck.inSeconds, lessThan(1));
          await cubit.close();
        },
      );

      blocTest<RCONCubit, RCONState>(
        'avoids retrying connection if health check fails',
        build: () {
          final server = buildServer();
          final fakeConnection = FakeRCONConnection(
            onSendCommand: (command) async {
              if (command == 'echo ping') {
                pingCount++;
                return Err(Exception('Connection lost'));
              }
              return Ok(buildPacket(body: 'response'));
            },
          );
          final connectionCache = ConnectionCache();

          return buildSubject(
            server: server,
            connectionCheckInterval: const Duration(milliseconds: 200),
            connect: Connect(
              getSocket: FakeGetSocket(onConnect: () => Future.value(Ok(fakeConnection))),
              addSocket: SaveConnection(connectionCache: connectionCache),
              removeSocket: DropConnection(connectionCache: connectionCache),
            ),
          );
        },
        wait: const Duration(seconds: 1),
        act: (bloc) async {
          // Allow some time for multiple health checks to occur
          await Future.delayed(const Duration(seconds: 1));
        },
        verify: (cubit) async {
          expect(pingCount, 1); // Only the first ping should increment count
          await cubit.close();
        },
      );
    });
  });
}
