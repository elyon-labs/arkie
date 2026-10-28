import 'package:arkie_state/features/rcon/server_info/models/pending_action.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/core_ui/rounded_superellipse_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';

class CancelPendingActionSnackBar extends StatelessWidget {
  const CancelPendingActionSnackBar({super.key, required this.pendingAction});

  final Option<PendingAction> pendingAction;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IgnorePointer(
        ignoring: pendingAction.isNone(),
        child: AnimatedOpacity(
          opacity: pendingAction.isSome() ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 100),
          child: RoundedSuperellipseBox(
            color: context.colors.body,
            child: Padding(
              padding: const EdgeInsets.all(Sizes.unit),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(switch (pendingAction) {
                      Some(:final some) => some.description,
                      _ => '',
                    }, style: context.text.caption),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<ServerInfoCubit>().clearPendingAction();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
