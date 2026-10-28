import 'package:arkie_core/features/rcon/domain/models/cs2_map.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/map_item.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/section_header.dart';
import 'package:dart_foundation/dart_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MapsSection extends StatelessWidget {
  const MapsSection({super.key, required this.padding});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final maps = context.select((ServerInfoCubit cubit) => cubit.state.maps);
    final workshopMaps = context.select((ServerInfoCubit cubit) => cubit.state.workshopMaps);
    final currentMap = context.select(
      (ServerInfoCubit cubit) => switch (cubit.state.status) {
        Loaded(:final value) => value.map,
        _ => null,
      },
    );
    if (maps.isEmpty && workshopMaps.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (maps.isNotEmpty)
            _MapGrid(
              title: 'maps',
              maps: maps,
              currentMap: currentMap,
              onTap: (m) async => await context.read<ServerInfoCubit>().changeMap(m),
            ),
          if (maps.isNotEmpty && workshopMaps.isNotEmpty) const VSpace(space: ArkieMetrics.loose),
          if (workshopMaps.isNotEmpty)
            _MapGrid(
              title: 'workshop maps',
              maps: workshopMaps,
              currentMap: currentMap,
              onTap: (m) async => await context.read<ServerInfoCubit>().changeMap(m),
            ),
        ],
      ),
    );
  }
}

class _MapGrid extends StatelessWidget {
  const _MapGrid({
    required this.title,
    required this.maps,
    required this.currentMap,
    required this.onTap,
  });

  final String title;
  final List<CS2Map> maps;
  final String? currentMap;
  final ValueSetter<CS2Map> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: Text(title)),
        const VSpace(space: ArkieMetrics.snug),
        GridView.builder(
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: ArkieMetrics.tight,
            crossAxisSpacing: ArkieMetrics.tight,
            childAspectRatio: 3.4,
          ),
          itemCount: maps.length,
          itemBuilder: (context, index) {
            final map = maps[index];
            return MapItem(map: map, isCurrentMap: _isCurrentMap(map, currentMap), onTap: onTap);
          },
        ),
      ],
    );
  }
}

bool _isCurrentMap(CS2Map map, String? currentMap) {
  if (currentMap == null) return false;
  if (map.name == currentMap) return true;
  return switch (map) {
    WorkshopMap(:final workshopId) => currentMap.contains(workshopId),
    KnownMap() => false,
  };
}
