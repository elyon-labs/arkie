# Arkie Mobile

The mobile companion to Arkie’s desktop RCON client. It shares its data and
domain layer (`arkie_core`), its cubits (`arkie_state`) and its theme
(`arkie_ui`, built from `ArkieTheme.mobile`) with the desktop app, while
presenting servers like a messages inbox and each server as a focused command
chat. Every colour comes from the theme through `context.colors`.

## Run locally

From the repository root:

```sh
melos bootstrap
cd apps/mobile/app
flutter run -d <ios-device-or-android-device>
```

Add a server from the empty state, then tap it to open the live console. Long-
press a command to save it; saved commands and map changes are available from
the tools button in the chat app bar.

## Shorebird and deployment

`shorebird.yaml` is checked in so this target is ready for Shorebird code push.
It contains only the public Shorebird app identifier. Run `shorebird init` in
this directory after the first Android and iOS builds to associate the app.

Release signing, Shorebird credentials, and deployment automation belong in
`elyon-labs/arkie-deployment`; this public repository intentionally contains no
deployment secrets or release workflow.
