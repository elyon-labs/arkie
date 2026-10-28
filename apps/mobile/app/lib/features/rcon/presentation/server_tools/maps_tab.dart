import 'package:arkie_core/features/rcon/domain/models/cs2_map.dart';
import 'package:arkie_core/features/rcon/domain/models/server_status.dart';
import 'package:arkie_mobile/core/widgets/centered_hint.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:dart_foundation/dart_foundation.dart' as app_async;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MapsTab extends StatelessWidget {
  const MapsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final serverInfoCubit = context.watch<ServerInfoCubit?>();
    if (serverInfoCubit == null) {
      return const CenteredHint('Connect to the server before changing maps.');
    }

    final maps = [
      ...context.select((ServerInfoCubit cubit) => cubit.state.maps),
      ...context.select((ServerInfoCubit cubit) => cubit.state.workshopMaps),
    ];
    final currentMap = context.select(
      (ServerInfoCubit cubit) => switch (cubit.state.status) {
        app_async.Loaded<ServerStatus>(:final value) => value.map,
        _ => null,
      },
    );

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: maps.length,
      separatorBuilder: (_, _) => const VSpace(),
      itemBuilder: (context, index) {
        final map = maps[index];
        return _MapTile(map: map, isCurrentMap: map.name == currentMap);
      },
    );
  }
}

class _MapTile extends StatelessWidget {
  const _MapTile({required this.map, required this.isCurrentMap});

  final CS2Map map;
  final bool isCurrentMap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: SizedBox(
          width: 44,
          height: 44,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(map.assetPath, package: CS2Map.assetPackage, fit: BoxFit.cover),
          ),
        ),
        title: Text(map.displayName),
        subtitle: Text(map.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Icon(
          isCurrentMap ? context.icons.check : Icons.arrow_forward_rounded,
          color: isCurrentMap ? context.colors.primary : null,
        ),
        onTap: () async {
          final result = await context.read<ServerInfoCubit>().changeMap(map);
          if (!context.mounted) return;
          if (result.isErr()) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('The server rejected the map change.')));
          }
        },
      ),
    );
  }
}
