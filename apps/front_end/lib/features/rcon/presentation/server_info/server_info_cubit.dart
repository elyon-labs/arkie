import 'dart:async';

import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core/safe_emit.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/ban_player.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/change_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/kick_player.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/player_info.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/server_status.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/watch_server_maps.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/watch_server_status.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/models/pending_action.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';
import 'package:rxdart/utils.dart';

class ServerInfoCubit extends Cubit<ServerInfoState> {
  ServerInfoCubit({
    required WatchServerStatus watchServerStatus,
    required WatchServerMaps watchServerMaps,
    required ChangeMap changeMap,
    required KickPlayer kickPlayer,
    required BanPlayer banPlayer,
  }) : _watchServerStatus = watchServerStatus,
       _watchServerMaps = watchServerMaps,
       _changeMap = changeMap,
       _kickPlayer = kickPlayer,
       _banPlayer = banPlayer,
       super(ServerInfoState.initial()) {
    unawaited(_init());
  }

  factory ServerInfoCubit.create({required RCONConnection connection}) {
    return ServerInfoCubit(
      watchServerStatus: WatchServerStatus.create(connection: connection),
      watchServerMaps: WatchServerMaps.create(connection: connection),
      changeMap: ChangeMap.create(connection: connection),
      kickPlayer: KickPlayer.create(connection: connection),
      banPlayer: BanPlayer.create(connection: connection),
    );
  }

  final WatchServerStatus _watchServerStatus;
  final WatchServerMaps _watchServerMaps;
  final ChangeMap _changeMap;
  final KickPlayer _kickPlayer;
  final BanPlayer _banPlayer;
  final CompositeSubscription _subs = CompositeSubscription();

  Future<void> _init() async {
    final mapsSub = _watchServerMaps().listen((maps) {
      safeEmit(state.copyWith(maps: maps));
    });
    final statusSub = _watchServerStatus().listen((status) {
      safeEmit(state.copyWith(status: Loaded(status)));
    });

    _subs
      ..add(mapsSub)
      ..add(statusSub);
  }

  void clearPendingAction() {
    safeEmit(state.copyWith(pendingAction: const None()));
  }

  Future<Result<void, Exception>> changeMap(CS2Map map) async {
    return switch (state.status) {
      Loaded<ServerStatus>(:final value) => () async {
        safeEmit(state.copyWith(pendingAction: Some(PendingMapChange(map))));
        await Future.delayed(const Duration(seconds: 3));
        final pendingMapChange = state.pendingAction.mapOr(
          (s) => switch (s) {
            PendingMapChange(:final map) => map,
            _ => null,
          },
          null,
        );
        if (pendingMapChange != map) return const Ok<void, Exception>(null);

        final result = await _changeMap(map);
        final newState = result.when(
          ok: (_) => state.copyWith(
            pendingAction: const None(),
            status: Loaded(value.copyWith(map: map.name)),
          ),
          err: (err) => state.copyWith(pendingAction: const None()),
        );
        safeEmit(newState);
        return const Ok<void, Exception>(null);
      }(),
      _ => Err(Exception('Cannot change map: server status is not loaded.')),
    };
  }

  Future<Result<void, Exception>> kickPlayer(PlayerInfo player) async {
    return switch (state.status) {
      Loaded<ServerStatus>() => () async {
        safeEmit(state.copyWith(pendingAction: Some(PendingKick(player))));
        await Future.delayed(const Duration(seconds: 3));
        final pendingKick = state.pendingAction.mapOr(
          (s) => switch (s) {
            PendingKick(:final player) => player,
            _ => null,
          },
          null,
        );
        if (pendingKick != player) return const Ok<void, Exception>(null);

        final result = await _kickPlayer(player.name);
        safeEmit(state.copyWith(pendingAction: const None()));
        return result;
      }(),
      _ => Err(Exception('Cannot kick player: server status is not loaded.')),
    };
  }

  Future<Result<void, Exception>> banPlayer(PlayerInfo player, {required Duration duration}) async {
    final steamId = player.steamId;

    if (steamId == null) {
      return Err(Exception('Cannot ban player: SteamID is null.'));
    }

    return switch (state.status) {
      Loaded<ServerStatus>() => () async {
        safeEmit(state.copyWith(pendingAction: Some(PendingBan(player, duration: duration))));
        await Future.delayed(const Duration(seconds: 3));
        final pendingBan = state.pendingAction.mapOr(
          (s) => switch (s) {
            PendingBan(:final player) => player,
            _ => null,
          },
          null,
        );
        if (pendingBan != player) return const Ok<void, Exception>(null);

        final result = await _banPlayer(steamId, duration: duration);
        safeEmit(state.copyWith(pendingAction: const None()));
        return result;
      }(),
      _ => Err(Exception('Cannot ban player: server status is not loaded.')),
    };
  }

  @override
  Future<void> close() async {
    await _subs.dispose();
    return super.close();
  }
}
