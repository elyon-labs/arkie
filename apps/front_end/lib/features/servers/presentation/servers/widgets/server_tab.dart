import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_state/features/servers/servers_cubit.dart';
import 'package:arkie_state/features/servers/servers_state.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// One tab in the strip along the top, in the manner of a terminal's window
/// list: the selected one is underlined in the accent, the rest are quiet.
class ServerTab extends HookWidget {
  const ServerTab({
    super.key,
    required this.tab,
    required this.server,
    required this.isSelected,
    required this.allowClose,
  });

  final OpenServerTab tab;
  final Server? server;
  final bool isSelected;
  final bool allowClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final arkie = context.arkieColors;
    final hovered = useState(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => hovered.value = true,
      onExit: (_) => hovered.value = false,
      child: GestureDetector(
        onTap: () => context.read<ServersCubit>().selectTab(tab.id),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          decoration: BoxDecoration(
            color: isSelected || hovered.value ? arkie.surfacePressed : null,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? colors.accent : Colors.transparent,
                width: ArkieMetrics.hairline * 2,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            left: ArkieMetrics.snug,
            right: allowClose ? ArkieMetrics.gutter : ArkieMetrics.snug,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                server?.name ?? 'new tab',
                style: context.text.caption.copyWith(
                  color: isSelected ? colors.foreground : colors.muted,
                ),
              ),
              if (allowClose) ...[
                const HSpace(space: ArkieMetrics.tight),
                IconButton(
                  iconSize: 12,
                  tooltip: 'Close tab',
                  onPressed: () => context.read<ServersCubit>().closeTab(tab.id),
                  icon: Icon(context.icons.close),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
