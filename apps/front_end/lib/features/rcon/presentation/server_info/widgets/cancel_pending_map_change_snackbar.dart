import 'package:arkie_state/features/rcon/server_info/models/pending_action.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';

/// The window in which an action can still be taken back, shown over the
/// sidebar it applies to.
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
          opacity: pendingAction.isSome() ? 1 : 0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.body,
              border: Border.all(
                color: context.arkieColors.borderStrong,
                width: ArkieMetrics.hairline,
              ),
            ),
            padding: const EdgeInsets.only(left: ArkieMetrics.snug),
            child: Row(
              children: [
                Expanded(
                  child: Text(switch (pendingAction) {
                    Some(:final some) => some.description,
                    _ => '',
                  }, style: context.text.caption.copyWith(color: context.colors.foreground)),
                ),
                TextButton(
                  onPressed: () => context.read<ServerInfoCubit>().clearPendingAction(),
                  child: const Text('Undo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
