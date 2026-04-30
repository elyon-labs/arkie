import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServerTab extends StatelessWidget {
  const ServerTab({super.key, required this.server, required this.isSelected});

  final Server server;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ServersCubit>().selectServer(server),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.sizes.unit * 2,
          vertical: context.sizes.unit,
        ),
        margin: EdgeInsets.all(context.sizes.unit / 2),
        decoration: isSelected
            ? ShapeDecoration(
                color: context.colors.selected,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(context.sizes.borderRadius),
                ),
              )
            : ShapeDecoration(
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(context.sizes.borderRadius),
                  side: BorderSide(color: context.colors.selected),
                ),
              ),
        child: Text(server.name),
      ),
    );
  }
}
