import 'dart:async';

import 'package:arkie_core/features/rcon/data/models/message.dart';
import 'package:arkie_core/features/rcon/data/models/saved_message.dart';
import 'package:arkie_core/features/rcon/data/repository/messages_repository.dart';
import 'package:arkie_core/features/rcon/domain/clear_messages.dart';
import 'package:arkie_core/features/rcon/domain/connect.dart';
import 'package:arkie_core/features/rcon/domain/rename_saved_message.dart';
import 'package:arkie_core/features/rcon/domain/save_message.dart';
import 'package:arkie_core/features/rcon/domain/send_command.dart';
import 'package:arkie_core/features/rcon/domain/unsave_message.dart';
import 'package:arkie_core/features/rcon/domain/watch_saved_messages.dart';
import 'package:arkie_core/features/rcon/domain/watch_server_messages.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_core/features/servers/domain/remove_server.dart';
import 'package:arkie_state/core/safe_emit.dart';
import 'package:arkie_state/features/rcon/rcon_state.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart' hide SendCommand;
import 'package:dart_foundation/dart_foundation.dart';
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
    if (_subs.isDisposed) return;

    final previousMonitor = _connectionMonitor;
    if (previousMonitor != null) {
      await _subs.remove(previousMonitor);
    }

    final monitor = Stream.periodic(_connectionCheckInterval).listen((_) async {
      await _checkConnection();
    });

    // The first connection attempt is awaited before the monitor starts, so the
    // cubit can be closed while it is still in flight, leaving nothing to
    // attach the monitor to.
    if (_subs.isDisposed) {
      _connectionMonitor = null;
      await monitor.cancel();
      return;
    }

    _connectionMonitor = monitor;
    _subs.add(monitor);
  }

  Future<Result<RCONConnection, Exception>> _testAndEmit() async {
    final inFlightCheck = _checkCompleter;
    if (inFlightCheck != null) {
      return inFlightCheck.future;
    }

    final completer = _checkCompleter = Completer<Result<RCONConnection, Exception>>();

    // A throw on the way to the server, rather than a reported failure, would
    // otherwise leave the connection stuck on Loading and this completer in
    // place, so every later check would wait on an answer that never comes.
    Result<RCONConnection, Exception> result;
    try {
      result = await _connect(
        address: _server.address,
        port: _server.port,
        password: _server.password,
        isDemo: _server.isDemo,
      );
    } catch (error) {
      result = Err(error is Exception ? error : Exception(error.toString()));
    } finally {
      _checkCompleter = null;
    }

    final newState = result.match(
      (c) {
        return state.copyWith(connection: Loaded(c));
      },
      (error) {
        return state.copyWith(connection: Error<RCONConnection>(error.toString()));
      },
    );

    completer.complete(result);

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
    if (connection.isOk()) {
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
