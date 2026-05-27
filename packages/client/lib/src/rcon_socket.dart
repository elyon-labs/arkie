import 'dart:async';
import 'dart:io';

import 'package:cs2_rcon_client/src/_log.dart';
import 'package:cs2_rcon_client/src/models/errors.dart';
import 'package:cs2_rcon_client/src/models/log.dart';
import 'package:cs2_rcon_client/src/models/rcon_packet.dart';
import 'package:cs2_rcon_client/src/rcon_connection.dart';
import 'package:cs2_rcon_client/src/rcon_server_packet_stream.dart';
import 'package:logger/logger.dart';
import 'package:oxidized/oxidized.dart';

/// {@template rcon_socket}
/// Manages the connection to the game server at the provided [hostAddress].
///
/// By default, the [hostPort] is set to 27015 and the [connectTimeout] is set
/// to 5 seconds.
///
/// The [connect] method establishes a connection to the game server with the
/// provided password and returns a [Result] based on the success of the
/// connection. If successful, a [RCONConnection] is returned that can be used
/// to send commands to the game server. Otherwise, an [Err] containing the
/// exception that occurred is returned.
/// {@endtemplate}
class RCONSocket {
  /// {@macro rcon_socket}
  RCONSocket({
    required this.hostAddress,
    this.hostPort = 27015,
    this.connectTimeout = const Duration(seconds: 5),
    this.commandTimeout = const Duration(milliseconds: 1500),
    this.logLevel = LogLevel.error,
  }) : _logger = Logger(level: logLevel.toLoggerLevel());

  /// The address of the game server.
  final InternetAddress hostAddress;

  /// The port of the game server.
  final int hostPort;

  /// The timeout for establishing a connection to the game server.
  final Duration connectTimeout;

  /// The timeout for sending commands to the game server.
  final Duration commandTimeout;

  /// The log level for the socket.
  final LogLevel logLevel;

  late final Socket _socket;
  late final SocketEvents _events;
  final Logger _logger;

  var _isClosed = false;
  StreamSubscription<RCONServerPacket>? _connectionMonitor;

  /// Queue to ensure sequential sending of packets. Start with an immediately completing
  /// future.
  Future<Result<void, Exception>> _sendQueue = Future.value(const Ok(null));

  /// Establishes a connection to the game server with the provided [password].
  Future<Result<RCONConnection, Exception>> connect({required String password}) async {
    return Result.asyncOf(() async {
      _socket = await Socket.connect(hostAddress, hostPort, timeout: connectTimeout);
      final rawEvents = _socket.asBroadcastStream();
      _events = RCONServerPacketStream(rawEvents).packets;

      // Detect unexpected connection close (e.g. server restart) and mark the
      // socket as closed so subsequent commands fail fast with a clear error.
      _connectionMonitor = _events.listen(
        null,
        onError: (_) {},
        onDone: () => _isClosed = true,
        cancelOnError: false,
      );

      final authRequestPacket = AuthorizationPacket(password);

      bool matchAuthResponsePacket(RCONServerPacket p) {
        _logger.t('Received auth response packet: $p');
        // ID matches the auth packet ID on success and -1 on failure
        return p.id == authRequestPacket.id || p.id == AuthorizationPacket.invalidAuthId;
      }

      final packetResponse = await _sendPacket(
        authRequestPacket,
        isMatch: matchAuthResponsePacket,
        timeout: connectTimeout,
      );

      _logger.t('Auth response: $packetResponse');

      return switch (packetResponse) {
        Ok<RCONServerPacket, Exception>(:final value) => () {
          if (value.id == AuthorizationPacket.invalidAuthId) {
            throw AuthorizationException('Invalid RCON password provided');
          } else {
            _isClosed = false;
            _logger.i('Successfully authenticated with RCON server at $hostAddress:$hostPort');
            final connection = RCONConnection(
              sendCommand: _sendCommandWithSentinel,
              closeConnection: _close,
            );
            return connection;
          }
        }(),
        Err<RCONServerPacket, Exception>(:final error) => throw error,
      };
    });
  }

  Future<Result<RCONServerPacket, Exception>> _sendCommandWithSentinel(String command) {
    return _enqueueSend(() => _sendCommandWithSentinelInternal(command));
  }

  Future<Result<RCONServerPacket, Exception>> _sendCommandWithSentinelInternal(
    String command,
  ) async {
    return Result.asyncOf(() async {
      final commandId = _RCONIdGenerator.next();

      // Main command
      final commandPacket = ExecCommandPacket.withCommand(command, id: commandId);

      // Sentinel: unique packet to signal end of multi-packet response
      // Use the same ID as the command so the server echoes responses with a consistent ID.
      final sentinelPacket = SentinelPacket(id: commandId, commandId: commandId);

      final fragments = <RCONServerPacket>[];

      bool matcher(RCONServerPacket p) {
        // Only care about packets for this command ID.
        if (p.id != commandId) return false;

        _logger.t('Received packet fragment:\n $p');

        if (p.type == ServerPacketType.SERVERDATA_RESPONSE_VALUE) {
          if (sentinelPacket.isOriginOf(p)) {
            // Stop listening, we've reached the sentinel.
            return true;
          }

          // Non-empty body: part of the response.
          fragments.add(p);
          // Keep listening, this isn't the sentinel yet.
          return false;
        }

        // Ignore other packet types (e.g. AUTH responses).
        return false;
      }

      final result = await _sendPacket(
        commandPacket,
        isMatch: matcher,
        extraPackets: [sentinelPacket],
      );

      if (result.isErr()) {
        throw result.unwrapErr();
      }

      if (fragments.isEmpty) {
        throw Exception('Received empty response for command: $command');
      }

      // Combine all fragments into one logical response.
      return fragments.combine();
    });
  }

  Future<Result<RCONServerPacket, Exception>> _sendPacket(
    RCONClientPacket packet, {
    required PacketMatcher isMatch,
    List<RCONPacket> extraPackets = const [],
    Duration? timeout,
  }) async {
    if (_isClosed) {
      _logger.e('Cannot send packet, socket is closed for sending');
      return Err(SocketClosedException('Cannot send packet, socket is closed for sending'));
    }

    return Result.asyncOf(() async {
      _logger.t('Sending packet: $packet');

      try {
        final responseFuture = _events.firstWhere(isMatch);

        _socket.add(packet.toBytes());
        for (final extra in extraPackets) {
          _socket.add(extra.toBytes());
        }

        return await responseFuture.timeout(
          timeout ?? commandTimeout,
          onTimeout: () {
            _logger.e('Timeout waiting for response to packet: $packet');
            throw CommandTimeoutException('Timeout waiting for response to packet: $packet');
          },
        );
      } on StateError {
        // StateError is thrown by Stream.firstWhere when the stream closes without
        // a matching element, and by IOSink.add when the sink is already closed.
        // Both indicate the connection was lost. Re-throw as a typed Exception so
        // Result.asyncOf can capture it correctly.
        _logger.e('Connection was closed while waiting for response to packet: $packet');
        throw SocketClosedException('Connection was closed while waiting for server response');
      }
    });
  }

  /// Closes the connection to the game server.
  Future<void> _close() async {
    await _connectionMonitor?.cancel();
    _connectionMonitor = null;
    await _socket.close();
    _isClosed = true;
  }

  /// Enqueues a send action to ensure sequential execution.
  /// This prevents race conditions when multiple commands are sent simultaneously.
  Future<Result<RCONServerPacket, Exception>> _enqueueSend(
    Future<Result<RCONServerPacket, Exception>> Function() action,
  ) {
    final completer = Completer<Result<RCONServerPacket, Exception>>();

    final previous = _sendQueue;

    _sendQueue = () async {
      // Await the previous send to ensure sequential execution.
      // Errors are intentionally ignored here: each send manages its own error
      // reporting via its own completer.
      try {
        await previous;
      } catch (e) {
        _logger.d('Ignored error from previous queued send: $e');
      }

      // Execute the current send action.
      return Result.asyncOf<void, Exception>(() async {
        final result = await action();

        if (!completer.isCompleted) completer.complete(result);
      });
    }();

    return completer.future;
  }
}

/// A stream of socket events received from the game server.
///
/// Each event is a packet of bytes that should be able to be parsed into
/// an [RCONServerPacket].
typedef SocketEvents = Stream<RCONServerPacket>;

/// A function that matches an [RCONServerPacket].
typedef PacketMatcher = bool Function(RCONServerPacket packet);

class _RCONIdGenerator {
  // Start somewhere in the middle of the valid range to avoid edge cases.
  static int _nextId = 1;

  // 32-bit signed, non-negative
  static int next() {
    // Wrap around before hitting negative range.
    if (_nextId == 0x7FFFFFFF) {
      _nextId = 1;
    }
    return _nextId++;
  }
}
