import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Says what went wrong and offers the one thing that fixes it.
class ConnectionErrorBanner extends StatelessWidget {
  const ConnectionErrorBanner({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.error, width: ArkieMetrics.hairline),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        ArkieMetrics.edge,
        ArkieMetrics.snug,
        ArkieMetrics.tight,
        ArkieMetrics.snug,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The server is not reachable.',
                  style: context.text.body.copyWith(color: colors.error),
                ),
                Text(
                  error,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.caption.copyWith(color: context.arkieColors.textFaint),
                ),
              ],
            ),
          ),
          const HSpace(space: ArkieMetrics.tight),
          TextButton(
            onPressed: () => context.read<RCONCubit>().retryConnection(),
            child: const Text('Reconnect'),
          ),
        ],
      ),
    );
  }
}
