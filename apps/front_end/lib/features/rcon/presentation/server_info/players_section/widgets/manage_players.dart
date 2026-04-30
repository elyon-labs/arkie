import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/player_info.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/players_section/widgets/ban_duration_dialog.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/section_header.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/sidebar_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagePlayers extends StatelessWidget {
  const ManagePlayers({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final players = context.select(
      (ServerInfoCubit cubit) => cubit.state.status.mapOr((s) {
        return s.players;
      }, <PlayerInfo>[]),
    );

    return SidebarWrapper(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, overscroll: false),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.sizes.edgeSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: const Text('Manage Players'),
                actions: [IconButton(onPressed: onClose, icon: Icon(context.icons.close))],
              ),
              SizedBox(height: context.sizes.unit * 2),
              for (final player in players)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(player.displayName),
                  subtitle: Text(player.description),
                  trailing: FractionalTranslation(
                    translation: const Offset(0.1, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: 'Kick ${player.name}',
                          child: IconButton(
                            onPressed: () async {
                              await context.read<ServerInfoCubit>().kickPlayer(player);
                            },
                            icon: Icon(context.icons.kick),
                          ),
                        ),
                        if (player.steamId64 != null)
                          Tooltip(
                            message: 'Ban ${player.name}',
                            child: IconButton(
                              onPressed: () async {
                                final banDuration = await showDialog<Duration?>(
                                  context: context,
                                  builder: (_) {
                                    return const BanDurationDialog();
                                  },
                                );
                                if (banDuration != null && context.mounted) {
                                  await context.read<ServerInfoCubit>().banPlayer(
                                    player,
                                    duration: banDuration,
                                  );
                                }
                              },
                              icon: Icon(context.icons.ban),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
