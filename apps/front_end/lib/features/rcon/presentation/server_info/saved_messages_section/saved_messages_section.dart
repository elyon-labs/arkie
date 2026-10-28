import 'package:arkie_core/features/rcon/data/models/saved_message.dart';
import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// The commands worth keeping, each one a line you can run. They carry the
/// prompt sigil because that is exactly what clicking one does.
class SavedMessagesSection extends StatelessWidget {
  const SavedMessagesSection({super.key, required this.onMenuTap, required this.padding});

  final VoidCallback onMenuTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final savedMessages = context.select((RCONCubit cubit) => cubit.state.savedMessages);

    if (savedMessages.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: const Text('commands'),
            actions: [IconButton(onPressed: onMenuTap, icon: Icon(context.icons.menu))],
          ),
          const VSpace(space: ArkieMetrics.tight),
          for (final message in savedMessages) _SavedMessageLine(message: message),
        ],
      ),
    );
  }
}

class _SavedMessageLine extends HookWidget {
  const _SavedMessageLine({required this.message});

  final SavedMessage message;

  @override
  Widget build(BuildContext context) {
    final hovered = useState(false);
    final colors = context.colors;

    return Tooltip(
      message: message.body,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => hovered.value = true,
        onExit: (_) => hovered.value = false,
        child: GestureDetector(
          onTap: () async => await context.read<RCONCubit>().sendCommand(message.body),
          child: ColoredBox(
            color: hovered.value ? context.arkieColors.surfacePressed : Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: ArkieMetrics.gutter / 2),
              child: Row(
                children: [
                  Text('>', style: context.text.caption.copyWith(color: colors.accent)),
                  const HSpace(space: ArkieMetrics.tight),
                  Expanded(
                    child: Text(
                      message.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.caption.copyWith(color: colors.foreground),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
