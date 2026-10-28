import 'package:arkie_core/features/rcon/domain/models/cs2_map.dart';
import 'package:arkie_core/features/rcon/domain/models/server_status.dart';
import 'package:arkie_mobile/core/widgets/centered_hint.dart';
import 'package:arkie_mobile/core/widgets/tool_row.dart';
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
      padding: const EdgeInsets.only(bottom: ArkieMetrics.loose),
      itemCount: maps.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final map = maps[index];
        return _MapRow(map: map, isCurrentMap: map.name == currentMap);
      },
    );
  }
}

class _MapRow extends StatelessWidget {
  const _MapRow({required this.map, required this.isCurrentMap});

  final CS2Map map;
  final bool isCurrentMap;

  @override
  Widget build(BuildContext context) {
    return ToolRow(
      title: map.displayName,
      subtitle: map.name,
      selected: isCurrentMap,
      leading: SizedBox(
        width: 36,
        height: 36,
        child: Image.asset(map.assetPath, package: CS2Map.assetPackage, fit: BoxFit.cover),
      ),
      trailing: isCurrentMap
          ? Text('loaded', style: context.text.caption.copyWith(color: context.colors.accent))
          : null,
      onTap: () async {
        final result = await context.read<ServerInfoCubit>().changeMap(map);
        if (!context.mounted) return;
        if (result.isErr()) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('The server rejected the map change.')));
        }
      },
    );
  }
}
