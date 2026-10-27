import 'package:cs2_rcon_front_end/core/async.dart' as app_async;
import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/server_status.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MapsTab extends StatelessWidget {
  const MapsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final serverInfoCubit = context.watch<ServerInfoCubit?>();
    if (serverInfoCubit == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Connect to the server before changing maps.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, height: 1.5),
          ),
        ),
      );
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
      separatorBuilder: (_, _) => const SizedBox(height: 8),
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
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: SizedBox(
          width: 44,
          height: 44,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(map.assetPath, package: 'cs2_rcon_front_end', fit: BoxFit.cover),
          ),
        ),
        title: Text(map.displayName),
        subtitle: Text(map.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Icon(
          isCurrentMap ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
          color: isCurrentMap ? Theme.of(context).colorScheme.primary : null,
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
