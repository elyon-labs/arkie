import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/map_item.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MapsSection extends StatelessWidget {
  const MapsSection({super.key, required this.padding});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final maps = context.select((ServerInfoCubit cubit) => cubit.state.maps);
    final currentMap = context.select(
      (ServerInfoCubit cubit) => switch (cubit.state.status) {
        Loaded(:final value) => value.map,
        _ => null,
      },
    );
    if (maps.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: Text('Maps')),
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
            itemCount: maps.length,
            itemBuilder: (context, index) {
              final map = maps[index];
              return MapItem(
                map: map,
                isCurrentMap: map.name == currentMap,
                onTap: (m) async => await context.read<ServerInfoCubit>().changeMap(m),
              );
            },
          ),
        ],
      ),
    );
  }
}
