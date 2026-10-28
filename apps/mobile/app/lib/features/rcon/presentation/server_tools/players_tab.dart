import 'package:arkie_core/features/rcon/domain/models/player_info.dart';
import 'package:arkie_core/features/rcon/domain/models/server_status.dart';
import 'package:arkie_mobile/core/widgets/centered_hint.dart';
import 'package:arkie_mobile/core/widgets/tool_row.dart';
import 'package:arkie_mobile/features/rcon/presentation/server_tools/widgets/ban_duration_sheet.dart';
import 'package:arkie_state/features/rcon/server_info/models/pending_action.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_cubit.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_state.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:dart_foundation/dart_foundation.dart' as app_async;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';

class PlayersTab extends StatelessWidget {
  const PlayersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final serverInfoCubit = context.watch<ServerInfoCubit?>();
    if (serverInfoCubit == null) {
      return const CenteredHint('Connect to the server to see who is online.');
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
      return const CenteredHint('No players are currently connected.');
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: ArkieMetrics.loose),
      itemCount: players.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) => _PlayerRow(player: players[index]),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final PlayerInfo player;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ServerInfoCubit>();

    return ToolRow(
      title: player.displayName,
      subtitle: player.description,
      leading: Icon(
        player.isBot ? context.icons.bot : context.icons.human,
        size: 18,
        color: context.colors.muted,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async => await cubit.kickPlayer(player),
            icon: Icon(context.icons.kick),
            tooltip: 'Kick',
          ),
          if (player.steamId64 != null)
            IconButton(
              onPressed: () async {
                final duration = await showBanDurationSheet(context);
                if (duration == null) return;
                await cubit.banPlayer(player, duration: duration);
              },
              icon: Icon(context.icons.ban),
              tooltip: 'Ban',
            ),
        ],
      ),
    );
  }
}
