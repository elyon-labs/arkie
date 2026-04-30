import 'dart:async';

import 'package:cs2_rcon_client/cs2_rcon_client.dart' hide SendCommand;
import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core/safe_emit.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/messages_repository.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/clear_messages.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/connect.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/rename_saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/save_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/send_command.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/unsave_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/watch_saved_messages.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/watch_server_messages.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_state.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/remove_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';
import 'package:rxdart/rxdart.dart';

class RCONCubit extends Cubit<RCONState> {
  RCONCubit({
    required Server server,
    required Connect connect,
    required WatchServerMessages watchServerMessages,
    required WatchSavedMessages watchedSavedMessages,
    required SendCommand sendCommand,
    required SaveMessage saveMessage,
    required UnsaveMessage unsaveMessage,
    required RenameSavedMessage renameSavedMessage,
    required RemoveServer removeServer,
    Duration? connectionCheckInterval,
  }) : _server = server,
       _connect = connect,
       _watchServerMessages = watchServerMessages,
       _watchSavedMessages = watchedSavedMessages,
       _sendCommand = sendCommand,
       _saveMessage = saveMessage,
       _unsaveMessage = unsaveMessage,
       _renameSavedMessage = renameSavedMessage,
       _removeServer = removeServer,
       _connectionCheckInterval = connectionCheckInterval ?? const Duration(seconds: 5),

       super(RCONState.initial(server)) {
    unawaited(_init());
  }

  factory RCONCubit.create({required BuildContext context, required Server server}) {
    final messagesRepository = context.read<MessagesRepository>();
    return RCONCubit(
      server: server,
      connect: Connect.create(),
      sendCommand: SendCommand(
        messagesRepository: messagesRepository,
        clearMessages: ClearMessages(messagesRepository: messagesRepository),
      ),
      saveMessage: SaveMessage(savedMessagesRepository: context.read()),
      unsaveMessage: UnsaveMessage(savedMessagesRepository: context.read()),
      renameSavedMessage: RenameSavedMessage(savedMessagesRepository: context.read()),
      removeServer: RemoveServer.create(messagesRepository: messagesRepository),
      watchServerMessages: WatchServerMessages(messagesRepository: messagesRepository),
      watchedSavedMessages: WatchSavedMessages(repository: context.read()),
    );
  }

  final Server _server;
  final Connect _connect;
  final WatchServerMessages _watchServerMessages;
  final WatchSavedMessages _watchSavedMessages;
  final SendCommand _sendCommand;
  final SaveMessage _saveMessage;
  final UnsaveMessage _unsaveMessage;
  final RenameSavedMessage _renameSavedMessage;
  final RemoveServer _removeServer;
  final Duration _connectionCheckInterval;
  Completer<Result<RCONConnection, Exception>>? _checkCompleter;

  final _subs = CompositeSubscription();
  StreamSubscription? _connectionMonitor;

  Future<void> _init() async {
    final messagesSub = _watchServerMessages.call().listen((messages) {
      safeEmit(state.copyWith(messages: List.of(messages)));
    });
    final savedMessagesSub = _watchSavedMessages.call().listen((savedMessages) {
      safeEmit(state.copyWith(savedMessages: List.of(savedMessages)));
    });

    _subs
      ..add(messagesSub)
      ..add(savedMessagesSub);

    await _testAndEmit();

    await _startConnectionMonitor();
  }

  Future<void> _startConnectionMonitor() async {
    if (_connectionMonitor != null) {
      await _subs.remove(_connectionMonitor!);
    }
    final sub = _connectionMonitor = Stream.periodic(_connectionCheckInterval).listen((_) async {
      await _checkConnection();
    });
    _subs.add(sub);
  }

  Future<Result<RCONConnection, Exception>> _testAndEmit() async {
    if (_checkCompleter != null) {
      return _checkCompleter!.future;
    }

    _checkCompleter = Completer();

    final result = _connect(
      address: _server.address,
      port: _server.port,
      password: _server.password,
    );

    final newState = await result.match(
      (c) {
        return state.copyWith(connection: Loaded(c));
      },
      (error) {
        return state.copyWith(connection: Error<RCONConnection>(error.toString()));
      },
    );

    _checkCompleter!.complete(result);
    _checkCompleter = null;

    safeEmit(newState.copyWith(lastConnectionCheckTime: DateTime.now()));

    return result;
  }

  Future<void> _checkConnection() async {
    final currentConnection = state.connection;

    // Only try to repair if we have a loaded connection
    if (currentConnection is! Loaded<RCONConnection>) {
      return;
    }

    final testResult = await _testAndEmit();

    if (testResult.isErr()) {
      // Connection is broken, close the current connection
      await currentConnection.value.close();

      // If reconnection failed, stop the monitor
      if (state.connection is Error<RCONConnection>) {
        await _connectionMonitor?.cancel();
        _connectionMonitor = null;
      }
    }
  }

  /// Retry establishing connection. Call this from the UI when connection is in error state.
  Future<void> retryConnection() async {
    safeEmit(state.copyWith(connection: const Loading<RCONConnection>()));

    final connection = await _testAndEmit();

    // Restart monitoring if connection succeeded
    if (connection is Loaded<RCONConnection>) {
      unawaited(_startConnectionMonitor());
    }
  }

  Future<void> sendCommand(String command) async {
    final connection = state.connection;
    if (connection is Loaded<RCONConnection>) {
      await _sendCommand(command, connection: connection.value);
    }
  }

  Future<void> saveMessage(Message message) async {
    await _saveMessage(message);
  }

  Future<void> unsaveMessage(SavedMessage message) async {
    await _unsaveMessage(message);
  }

  Future<void> renameSavedMessage(String id, String newName) async {
    await _renameSavedMessage(id: id, newName: newName);
  }

  Future<Result<void, Exception>> removeServer(Server server) async {
    return _removeServer(server);
  }

  @override
  Future<void> close() async {
    await _subs.dispose();
    _connectionMonitor = null;
    // We purposefully do not close the RCON connection here,
    // as it is managed by the ConnectionCache.
    await super.close();
  }
}
