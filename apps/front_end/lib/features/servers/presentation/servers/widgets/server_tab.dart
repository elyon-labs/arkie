import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_state/features/servers/servers_cubit.dart';
import 'package:arkie_state/features/servers/servers_state.dart';
import 'package:arkie_ui/arkie_ui.dart';
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
    const horizontalPadding = Sizes.unit * 1.5;
    const verticalPadding = Sizes.unit;
    const closeButtonSize = Sizes.unit * 3;

    return GestureDetector(
      onTap: () => context.read<ServersCubit>().selectTab(tab.id),
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
        margin: const EdgeInsets.all(Sizes.unit / 2),
        decoration: isSelected
            ? ShapeDecoration(
                color: context.colors.selected,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                ),
              )
            : ShapeDecoration(
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                  side: BorderSide(color: context.colors.selected),
                ),
              ),
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            top: verticalPadding,
            bottom: verticalPadding,
            right: allowClose ? Sizes.unit / 2 : horizontalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(server?.name ?? 'New tab'),
              if (allowClose) ...[
                const HSpace(space: Sizes.unit / 2),
                SizedBox.square(
                  dimension: closeButtonSize,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: closeButtonSize,
                      height: closeButtonSize,
                    ),
                    iconSize: Sizes.unit * 1.5,
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
