# arkie_ui

The theme shared by Arkie's desktop and mobile apps, built on the Elyon Labs
[design system](https://github.com/elyon-labs/flutter-design), which this package re-exports.

Each app's theme is an `ArkieTheme`: a brightness, an `ElyonColors` palette, an `ArkieIcons` set
and a font. `ArkieTheme.desktopDark`, `ArkieTheme.desktopLight` and `ArkieTheme.mobile` are the
three in use, turned into `ThemeData` by `buildDesktopTheme` and `buildMobileTheme`. The Material
`ColorScheme` is derived from the palette too, so unstyled Material widgets match.

In widgets, read every colour from the theme rather than writing one down:

```dart
import 'package:arkie_ui/arkie_ui.dart';

Text('LIVE', style: TextStyle(color: context.colors.good));
Icon(context.icons.server, color: context.colors.muted);
```

The Space Mono font ships here; `ArkieTheme.spaceMono` names it.
