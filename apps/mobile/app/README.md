# Arkie Mobile

The mobile companion to Arkie’s desktop RCON client. It keeps the same local
server, message, and saved-command storage as the desktop app while presenting
servers like a messages inbox and each server as a focused command chat.

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
