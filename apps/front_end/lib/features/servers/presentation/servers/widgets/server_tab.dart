import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_cubit.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServerTab extends StatelessWidget {
  const ServerTab({
    super.key,
    required this.tab,
    required this.server,
    required this.isSelected,
    required this.allowClose,
  });

  final OpenServerTab tab;
  final Server? server;
  final bool isSelected;
  final bool allowClose;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.sizes.unit * 1.5;
    final verticalPadding = context.sizes.unit;
    final closeButtonSize = context.sizes.unit * 3;

    return GestureDetector(
      onTap: () => context.read<ServersCubit>().selectTab(tab.id),
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
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
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            top: verticalPadding,
            bottom: verticalPadding,
            right: allowClose ? context.sizes.unit / 2 : horizontalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(server?.name ?? 'New tab'),
              if (allowClose) ...[
                SizedBox(width: context.sizes.unit / 2),
                SizedBox.square(
                  dimension: closeButtonSize,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(
                      width: closeButtonSize,
                      height: closeButtonSize,
                    ),
                    iconSize: context.sizes.unit * 1.5,
                    tooltip: 'Close tab',
                    onPressed: () => context.read<ServersCubit>().closeTab(tab.id),
                    icon: Icon(context.icons.close),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
