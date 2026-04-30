# CS2 RCON Client

`cs2_rcon_client` is a pure Dart implementation of the Source RCON protocol that powers both the CLI (`packages/cli`) and the Flutter desktop UI (`apps/front_end`). It focuses on being small, async-friendly, and explicit about success/error states.

## Key capabilities

- Establish an authenticated TCP connection to a CS2 server via `RCONSocket.connect`.
- Send commands through `RCONConnection.sendCommand`, receiving strongly typed `Result<RCONServerPacket, Exception>` values from `oxidized`.
- Tune logging verbosity (`debug`, `info`, `error`) through `LogLevel`, which is backed by `mason_logger`.
- Surface timeout, authorization, and socket-closed conditions with dedicated exception classes.
- Facilitate local testing using the bundled `FakeRCONServer` in `test/fakes/fake_rcon_server.dart`.

> ⚠️ This package talks directly to `dart:io` sockets, so it targets the Dart VM (desktop/server) rather than the web.

## Installation

Inside this monorepo the package is referenced via a relative path:

```yaml
dependencies:
  cs2_rcon_client:
    path: ../packages/client   # adjust the path based on your package location
```

There is no published version yet; consuming it from the repo keeps the CLI and Flutter app on the same build.

## Quick start

```dart
import 'dart:io';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';

Future<void> main() async {
  final socket = RCONSocket(
    hostAddress: InternetAddress('192.168.1.100'),
    hostPort: 27015,
    logLevel: LogLevel.info,
  );

  final connectionResult = await socket.connect(password: 'hunter2');

  connectionResult.match(
    (connection) async {
      final response = await connection.sendCommand('status');

      response.match(
        (packet) => print(packet.body),
        (error) => print('Command failed: $error'),
      );

      await connection.close();
    },
    (error) => stderr.writeln('Failed to connect: $error'),
  );
}
```

## Handling errors explicitly

Because every async operation returns a `Result`, you never have to rely on thrown exceptions:

```dart
final connection = await socket.connect(password: 'hunter2');

switch (connection) {
  case Ok(value: final rcon):
    final result = await rcon.sendCommand('changelevel de_inferno');
    switch (result) {
      case Ok(value: final packet):
        print('Server replied:\n${packet.body}');
      case Err(value: final err):
        if (err is CommandTimeoutException) {
          print('Server took too long to respond.');
        } else {
          print('Command failed: $err');
        }
    }
  case Err(value: final err):
    if (err is AuthorizationException) {
      print('Bad RCON password.');
    } else {
      print('Socket failed: $err');
    }
}
```

## Configuration reference

`RCONSocket` accepts a few knobs:

```dart
final socket = RCONSocket(
  hostAddress: InternetAddress('10.0.0.5'),
  hostPort: 27016,                             // defaults to 27015
  connectTimeout: const Duration(seconds: 3),  // defaults to 5 seconds
  logLevel: LogLevel.debug,                    // defaults to LogLevel.error
);
```

`RCONConnection.sendCommand` reuses the same timeout that was configured on the socket and automatically stitches multi-packet responses together (see the `combine` extension on `Iterable<RCONServerPacket>` in `lib/src/models/rcon_packet.dart`).

## Testing & local development

| Task | Command |
| --- | --- |
| Install deps | `dart pub get` |
| Run tests | `dart test` |
| Format | `dart format lib test` |
| Analyze | `dart analyze` |

### Fake server utility

`packages/client/test/fakes/fake_rcon_server.dart` spins up a minimal RCON-compliant TCP server. You can use it in tests or manual experiments:

```dart
final fake = FakeRCONServer(
  password: 'hunter2',
  onCommand: (command) async => 'echo $command',
);
await fake.start();
// ...connect with RCONSocket...
await fake.stop();
```

The CLI and Flutter app both rely on the same API surface, so expanding test coverage here automatically benefits every consumer.

## Relationship to other packages

- `apps/cli` (`rcon connect`) uses this library to perform the actual networking work.
- `apps/front_end` injects `RCONSocket` via `SocketBuilder` so the UI and CLI stay in sync.

For contribution guidelines and repository-wide tooling tips, see the [root README](../../README.md).
