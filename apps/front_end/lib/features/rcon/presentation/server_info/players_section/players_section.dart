import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/core_ui/rounded_superellipse_box.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/player_info.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayersSection extends StatelessWidget {
  const PlayersSection({super.key, required this.onMenuTap, required this.padding});

  final VoidCallback onMenuTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final players = context.select(
      (ServerInfoCubit cubit) => cubit.state.status.mapOr((s) {
        return s.players;
      }, <PlayerInfo>[]),
    );

    if (players.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: const Text('Players'),
            actions: [IconButton(onPressed: onMenuTap, icon: Icon(context.icons.menu))],
          ),
          SizedBox(height: context.sizes.unit * 2),
          GridView.builder(
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: context.sizes.unit,
              crossAxisSpacing: context.sizes.unit * 2,
              childAspectRatio: 4,
            ),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return _PlayerItem(player: player);
            },
          ),
        ],
      ),
    );
  }
}

class _PlayerItem extends StatelessWidget {
  const _PlayerItem({required this.player});

  final PlayerInfo player;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: player.description,
      child: RoundedSuperellipseBox(
        color: context.colors.backgroundSecondary,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.sizes.unit),
            child: Text(player.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}
