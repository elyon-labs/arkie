# arkie_core

The data and domain layer shared by Arkie's desktop (`apps/front_end`) and mobile
(`apps/mobile/app`) apps.

- `features/*/data` – Hive- and `RxSharedPreferences`-backed APIs, repositories and models for
  servers, messages, saved commands and settings.
- `features/*/domain` – the use cases the apps' cubits call (`Connect`, `SendCommand`,
  `ChangeMap`, `KickPlayer`, …).
- `di/graph.dart` – `setUpGraph` and `inject`, the `get_it` graph both apps bootstrap in `main`.
- `hive/` – the generated Hive adapters; call `Hive.registerAdapters()` before opening boxes.
- `assets/maps/` – map preview images. Load them with
  `Image.asset(map.assetPath, package: CS2Map.assetPackage)`.
- `testing.dart` – fakes for tests of code built on this package.

Run `dart run tool/update_hla_workshop_maps.dart` from this directory to refresh the workshop map
list and images. After editing a model, run `melos run codegen` from the repository root.
