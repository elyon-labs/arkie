import 'package:arkie_core/features/rcon/domain/models/player_info.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/section_header.dart';
import 'package:dart_foundation/dart_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Who is on the server, one per line. A grid of tiles made two columns of
/// truncated names out of what is really a roster.
class PlayersSection extends StatelessWidget {
  const PlayersSection({super.key, required this.onMenuTap, required this.padding});

  final VoidCallback onMenuTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final players = context.select(
      (ServerInfoCubit cubit) => cubit.state.status.mapOr((s) => s.players, <PlayerInfo>[]),
    );

    if (players.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: const Text('players'),
            actions: [IconButton(onPressed: onMenuTap, icon: Icon(context.icons.menu))],
          ),
          const VSpace(space: ArkieMetrics.tight),
          for (final player in players) _PlayerLine(player: player),
        ],
      ),
    );
  }
}

class _PlayerLine extends StatelessWidget {
  const _PlayerLine({required this.player});

  final PlayerInfo player;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: player.description,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: ArkieMetrics.gutter / 2),
        child: Row(
          children: [
            Icon(
              player.isBot ? context.icons.bot : context.icons.human,
              size: 13,
              color: context.arkieColors.textFaint,
            ),
            const HSpace(space: ArkieMetrics.tight),
            Expanded(
              child: Text(
                player.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.caption.copyWith(color: context.colors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
