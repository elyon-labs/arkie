# arkie_ui

The theme shared by Arkie's desktop and mobile apps, built on the Elyon Labs
[design system](https://github.com/elyon-labs/flutter-design), which this package re-exports.

Arkie is drawn as a terminal, because a remote console is what it is. Panes are outlines rather
than fills, with their label notched into the top border; corners are square; monospace is the
only face; and the purple accent is spent only on your own input and the current selection, so
the server's output stays plain and readable.

```
┌─ server ──────────────────── ■ live ─┐
│ address.................10.0.0.4     │
│ players......................12/24   │
└──────────────────────────────────────┘
```

## Themes

Each app's theme is an `ArkieTheme`: a brightness, an `ElyonColors` palette, the Arkie-specific
`ArkieColors`, an `ArkieIcons` set and a font. `ArkieTheme.desktop` and `ArkieTheme.mobile` are the
two in use, turned into `ThemeData` by `buildDesktopTheme` and `buildMobileTheme`. Both are dark —
the terminal aesthetic has no light counterpart — and both are set in Space Mono, which ships here
and is named by `ArkieTheme.spaceMono`. The Material `ColorScheme` is derived from the palette too,
so unstyled Material widgets match.

Read every colour from the theme rather than writing one down. `context.colors` has the design
system's roles; `context.arkieColors` has the terminal-specific ones (`border`, `borderStrong`,
`textFaint`, `surfacePressed`, `accentSurface`, `backdrop`):

```dart
import 'package:arkie_ui/arkie_ui.dart';

Text(name, style: TextStyle(color: context.arkieColors.textFaint));
Icon(context.icons.server, color: context.colors.muted);
```

`ArkieMetrics` holds what the panes are drawn on: `hairline`, the square `corner` and `shape`, and
the spacing steps. `Sizes` from the design system still supplies the 8pt grid.

## Widgets

| Widget | What it is |
| --- | --- |
| `TerminalPanel` | A pane drawn as an outline, with its label and an optional trailing widget notched into the top border. |
| `ConsoleLine` | One line of console traffic — your command with the prompt sigil and the accent, or the server's reply, plain and in the same column. |
| `LabelValue` | A label and value joined by dot leaders, so a stack of them lands every value on one column. |
| `DotLeaders` | The run of dots itself, if you need it outside `LabelValue`. |
| `StatusLamp` | A square lamp and a word for a `LinkState` (`live`, `connecting`, `offline`). |
