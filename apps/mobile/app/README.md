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

## App Store assets

The listing — every field App Store Connect asks for, and the notes review needs — is written out
in [`docs/app-store.md`](docs/app-store.md). The art it refers to is committed under
`assets/store`, so nothing has to be re-rendered to submit.

Both scripts are run deliberately, from this directory, and neither runs in CI:

| Command                                  | Produces                                                     |
| ---------------------------------------- | ------------------------------------------------------------ |
| `dart run tool/capture_screenshots.dart` | `assets/store/screenshots`, at 1206x2622 (iPhone 6.1"/6.3"). |
| `dart run tool/render_store_assets.dart` | The product page header and search results images.           |

From the repository root they are `melos run store:screenshots` and `melos run store:render`.

`tool/capture_screenshots.dart` creates a simulator of its own, builds
[`lib/main_screenshots.dart`](lib/main_screenshots.dart) once per scene, and captures each one; pass
a udid to use a simulator you already have instead. The screenshot entry point is the real app over
a canned Hive store, talking to the in-app demo server, so what the screenshots show is what the app
does. Adding or reordering a scene means editing the `Scene` enum there and the `scenes` list in the
script together.

`tool/render_store_assets.dart` needs Google Chrome; it draws both images from the app's own
palette and the Space Mono it renders in.

## Shorebird and deployment

`shorebird.yaml` is checked in so this target is ready for Shorebird code push.
It contains only the public Shorebird app identifier. Run `shorebird init` in
this directory after the first Android and iOS builds to associate the app.

Release signing, Shorebird credentials, and deployment automation belong in
`elyon-labs/arkie-deployment`; this public repository intentionally contains no
deployment secrets or release workflow.
