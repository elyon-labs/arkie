import 'package:arkie_mobile/features/rcon/presentation/server_tools/widgets/ban_duration_sheet.dart';
import 'package:cs2_rcon_front_end/core/async.dart' as app_async;
import 'package:cs2_rcon_front_end/features/rcon/domain/models/player_info.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/server_status.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/models/pending_action.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';

class PlayersTab extends StatelessWidget {
  const PlayersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final serverInfoCubit = context.watch<ServerInfoCubit?>();
    if (serverInfoCubit == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Connect to the server to see who is online.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, height: 1.5),
          ),
        ),
      );
    }

    return BlocListener<ServerInfoCubit, ServerInfoState>(
      listenWhen: (previous, current) => current.pendingAction is Some<PendingAction>,
      listener: (context, state) {
        final pendingAction = state.pendingAction;
        if (pendingAction is! Some<PendingAction>) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(pendingAction.some.description),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => context.read<ServerInfoCubit>().clearPendingAction(),
              ),
            ),
          );
      },
      child: Builder(
        builder: (context) {
          final status = context.select((ServerInfoCubit cubit) => cubit.state.status);
          return switch (status) {
            app_async.Loaded<ServerStatus>(:final value) => _PlayerList(players: value.players),
            app_async.Error(:final error) => Center(child: Text('Error loading players: $error')),
            _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }
}

class _PlayerList extends StatelessWidget {
  const _PlayerList({required this.players});

  final List<PlayerInfo> players;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No players are currently connected.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: players.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _PlayerTile(player: players[index]),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({required this.player});

  final PlayerInfo player;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ServerInfoCubit>();
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(player.isBot ? Icons.smart_toy_outlined : Icons.person_outline_rounded),
        title: Text(player.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(player.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async => await cubit.kickPlayer(player),
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Kick',
            ),
            if (player.steamId64 != null)
              IconButton(
                onPressed: () async {
                  final duration = await showBanDurationSheet(context);
                  if (duration == null) return;
                  await cubit.banPlayer(player, duration: duration);
                },
                icon: const Icon(Icons.block_rounded),
                tooltip: 'Ban',
              ),
          ],
        ),
      ),
    );
  }
}
