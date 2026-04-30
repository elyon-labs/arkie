import 'package:cs2_rcon_front_end/app/presentation/app_cubit.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeModeRow extends StatelessWidget {
  const ThemeModeRow({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select((AppCubit cubit) => cubit.state.themeMode);

    Future<void> setThemeMode(ThemeMode mode) async {
      await context.read<AppCubit>().setThemeMode(mode);
    }

    return ListTile(
      title: const Text('App theme'),
      subtitle: switch (themeMode) {
        ThemeMode.light => const Text('Always use light theme'),
        ThemeMode.dark => const Text('Always use dark theme'),
        ThemeMode.system => const Text('Follow system theme'),
      },
      trailing: MenuAnchor(
        menuChildren: [
          MenuItemButton(
            child: const _MenuItem('Light'),
            onPressed: () => setThemeMode(ThemeMode.light),
          ),
          MenuItemButton(
            child: const _MenuItem('Dark'),
            onPressed: () => setThemeMode(ThemeMode.dark),
          ),
          MenuItemButton(
            child: const _MenuItem('System'),
            onPressed: () => setThemeMode(ThemeMode.system),
          ),
        ],
        builder: (context, controller, child) {
          final text = switch (themeMode) {
            ThemeMode.light => 'Light',
            ThemeMode.dark => 'Dark',
            ThemeMode.system => 'System',
          };
          return InkResponse(
            mouseCursor: SystemMouseCursors.click,
            containedInkWell: true,
            highlightShape: BoxShape.rectangle,
            customBorder: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(context.sizes.borderRadius),
            ),
            onTap: () => controller.isOpen ? controller.close() : controller.open(),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: RoundedSuperellipseBorder(
                  side: BorderSide(color: context.colors.border),
                  borderRadius: BorderRadius.circular(context.sizes.borderRadius),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.sizes.edgeSpacing,
                  vertical: context.sizes.unit,
                ),
                child: Text(text, style: context.text.title),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.sizes.edgeSpacing),
      child: Text(text),
    );
  }
}
