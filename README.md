# CS2 RCON

![Arkie desktop app screenshot](apps/front_end/images/arkie.png)

CS2 RCON is a Melos-managed Dart/Flutter monorepo for experimenting with Counter-Strike 2 (CS2) Remote Console workflows. It contains a pure Dart client for the Source RCON protocol, a terminal experience built on top of that client, and two Flutter apps — Arkie for desktop and Arkie for mobile — that share their data, state and theme through packages in this repository. It also holds the public website for the app, which is an Astro site rather than a Dart package and is managed by pnpm alongside Melos.

## Repository layout

| Path              | Component                                                                                             |
| ----------------- | ----------------------------------------------------------------------------------------------------- |
| `packages/client` | `cs2_rcon_client`, a reusable RCON socket + connection abstraction built on `dart:io` and `oxidized`. |
| `packages/core`   | `arkie_core`, the apps' shared data and domain layer: storage, repositories, use cases, dependency injection and the map images. |
| `packages/state`  | `arkie_state`, the apps' shared presentation state: `RCONCubit`, `ServerInfoCubit`, `ServersCubit` and friends. |
| `packages/ui`     | `arkie_ui`, the apps' shared theme: one `ArkieTheme` object per app, built on the Elyon Labs design system. |
| `apps/cli`        | `cs2_rcon_cli`, the `rcon connect` command that lets you type commands directly from a terminal.      |
| `apps/front_end`  | `cs2_rcon_front_end`, the Flutter desktop app for saving servers and chatting with them over RCON.    |
| `apps/mobile/app` | `arkie_mobile`, the Flutter iOS/Android app: servers as an inbox, each server as a command chat.     |
| `apps/web`        | `@arkie/web`, the website at [arkie.elyon-labs.com](https://arkie.elyon-labs.com). Astro, deployed to Cloudflare. |

Two Elyon Labs libraries come in as git dependencies:
[`dart_foundation`](https://github.com/elyon-labs/dart-foundation) for primitives such as
`Async<T>`, and [`design`](https://github.com/elyon-labs/flutter-design) for the theme extensions
(`ElyonColors`, `ElyonText`), `Sizes` and the spacing widgets.

## Architecture at a glance

```
+---------------------------+     +---------------------------+
| Flutter desktop app       |     | Flutter mobile app        |
| apps/front_end            |     | apps/mobile/app           |
+-------------+-------------+     +-------------+-------------+
              |                                 |
              +----------------+----------------+
                               | depend on
                               v
   +------------------------+  +------------------------+
   | arkie_state            |  | arkie_ui               |
   | packages/state         |  | packages/ui            |
   | cubits + their states  |  | ArkieTheme, icons      |
   +-----------+------------+  +-----------+------------+
               |                           |
               v                           v
   +------------------------+  +------------------------+
   | arkie_core             |  | design (flutter-design)|
   | packages/core          |  +------------------------+
   | data, domain, DI       |
   +-----------+------------+
               |                 persists servers, messages and settings via
               |                 Hive and RxSharedPreferences (local only)
               v
+----------------+     uses      +-----------------------+     TCP (RCON)     +------------------------+
| CLI (apps/cli, | ------------> | Dart RCON client      | -----------------> | Counter-Strike 2       |
| rcon cmd)      |               | packages/client       |                    | server (RCON endpoint) |
+----------------+               +-----------------------+                    +------------------------+
```

`arkie_core` and `arkie_state` also depend on `dart_foundation` for shared primitives like `Async<T>`.
Neither app depends on the other: anything both use lives in a package.

## Getting started

1. Install Flutter 3.35.7+ (which ships with Dart >=3.9.0). Desktop targets must be enabled for the platforms you want to run (`flutter config --enable-<platform>-desktop`); the mobile app also needs Xcode (iOS) or the Android SDK.
2. Install Melos once: `dart pub global activate melos`.
3. Bootstrap the workspace from the repo root:

```bash
melos bootstrap
```

This runs `flutter pub get`/`dart pub get` for every package and wires up path dependencies.

4. For the website only, install Node and pnpm — [`mise.toml`](mise.toml) pins both, so `mise install` is enough — and run `pnpm install` from the repo root.

### Common Melos scripts

All scripts are defined in the `melos` section of [`pubspec.yaml`](pubspec.yaml):

| Command                                                      | Purpose                                                                                 |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| `melos run format:flutter`                                   | Format every Flutter project.                                                           |
| `melos run format:dart`                                      | Format Dart-only packages.                                                              |
| `melos run analyze:flutter:ci` / `melos run analyze:dart:ci` | Static analysis with warnings promoted to errors.                                       |
| `melos run test:flutter:ci` / `melos run test:dart:ci`       | Run the Flutter/Dart test suites when a `test/` folder exists.                          |
| `melos run codegen`                                          | Runs `build_runner` anywhere it is available (`dart_mappable` models and Hive adapters). |

### The website

`apps/web` is JavaScript, so it sits outside Melos and is driven from the root `package.json`
instead. Install its dependencies once with `pnpm install`, then:

| Command              | Purpose                                     |
| -------------------- | ------------------------------------------- |
| `pnpm web:dev`       | Serve the site at http://localhost:4321.    |
| `pnpm web:build`     | Build it into `apps/web/dist`.              |
| `pnpm web:typecheck` | `astro sync && tsc --noEmit`.               |
| `pnpm web:deploy`    | Build and upload it to Cloudflare.          |

See [`apps/web/README.md`](apps/web/README.md) for how the release notes, the download links and
the theme are put together.

## Component documentation

Each package/app ships with its own README that dives into usage details:

- [`apps/front_end`](apps/front_end/README.md) – Flutter desktop UI, server list management, and realtime command view.
- [`apps/mobile/app`](apps/mobile/app/README.md) – Flutter mobile app: server inbox, command chat, and server tools.
- [`apps/web`](apps/web/README.md) – The public site: landing page, downloads, release notes and legal pages.
- [`packages/client`](packages/client/README.md) – Reusable RCON client library (sockets, packets, logging).
- [`packages/core`](packages/core/README.md) – Shared data and domain layer for both apps.
- [`packages/state`](packages/state/README.md) – Shared cubits and states for both apps.
- [`packages/ui`](packages/ui/README.md) – Shared theme for both apps.
- [`apps/cli`](apps/cli/README.md) – The terminal command (`rcon connect`) built on top of the client.

## Releases and support

This repository contains the public source code, documentation, and pull request checks. Release signing, notarisation, release tags, and binary asset publishing are handled outside of the public repository so signing credentials and release automation stay private.

Use the GitHub issue tracker for bug reports and feature requests. Please do not include real RCON passwords, private server addresses, or other secrets in issues, discussions, logs, or screenshots.

## Contributing

- Prefer running commands through Melos so that every package stays consistent.
- When editing models in `packages/core` or states in `packages/state`, re-run `melos run codegen` to regenerate the `dart_mappable` and Hive files.
- Code used by both apps belongs in a package, never in one app imported by the other. Colours come from the app's `ArkieTheme` (`context.colors`), not from literals.
- The repo currently targets local networks; make sure the CS2 server’s RCON port is reachable from your machine (default `27015`).
- See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full local development and pull request workflow.
