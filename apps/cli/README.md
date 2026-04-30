# CS2 RCON CLI

`cs2_rcon_cli` is a lightweight terminal client that wraps the shared `cs2_rcon_client` package so you can log in to a Counter-Strike 2 server and issue RCON commands from any shell.

## What it currently supports

- A single `connect` command that authenticates with a CS2 RCON endpoint and drops you into an interactive prompt.
- Streaming command execution: every line you enter (other than `exit`) is sent via the underlying `RCONConnection`, and responses are echoed back immediately.
- Optional logging verbosity via `--log-level` (`debug`, `info`, `error`) powered by `mason_logger`.
- Reuse inside scripts by piping input or by typing manually.

## Requirements

- Dart SDK ≥3.8.1 (ships with Flutter 3.24+).
- Network access to the CS2 server’s RCON port (default `27015`).

## Running from the repo

```bash
cd packages/cli
dart pub get
dart run bin/cli.dart connect \
  --address 192.168.1.50 \
  --password "superSecret" \
  --port 27015 \
  --log-level info
```

Type your RCON command when prompted; enter `exit` or press `Ctrl+C` to end the session. The tool keeps the TCP connection open until you close it, so you can send multiple commands without re-authenticating.

### Global activation (optional)

`pubspec.yaml` exposes the executable as `rcon`, so you can install it globally for easier access:

```bash
dart pub global activate --source path packages/cli
rcon connect -a 192.168.1.50 -p "superSecret" -P 27015
```

Update `PATH` to include `~/.pub-cache/bin` if it is not already there.

## Command reference

`connect` options:

| Flag | Description |
| --- | --- |
| `-a`, `--address` | **Required.** Server IP or hostname. |
| `-P`, `--port` | Optional. Defaults to `27015`. |
| `-p`, `--password` | **Required.** RCON password configured in the CS2 server. |
| `-l`, `--log-level` | Optional. `debug`, `info`, or `error` (default `info`). Controls socket logging. |

Example session:

```
$ rcon connect -a 192.168.1.50 -p hunter2
Authenticating with server... ✓
Enter command: status
Response:
hostname: My CS2 Server
version : 1.39.8.4 ...

Enter command: exit
Exiting...
```

## Development tasks

| Task | Command |
| --- | --- |
| Format | `dart format bin lib` |
| Analyze | `dart analyze` |
| Tests | *(none yet — contributions welcome!)* |

Because the CLI relies entirely on `cs2_rcon_client`, you can use the fake RCON server in `packages/client/test/fakes` to exercise the workflow in isolation.
