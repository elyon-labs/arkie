import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:dart_foundation/dart_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The status line under the prompt, carrying the state of the link and, when
/// it is down, the reason and the way back.
class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.select((RCONCubit cubit) => cubit.state);
    final lastChecked = state.lastConnectionCheckTime;

    final line = switch (state.connection) {
      Loaded<RCONConnection>() => const StatusLamp(state: LinkState.live),
      Error<RCONConnection>(:final error) => Row(
        children: [
          const StatusLamp(state: LinkState.offline),
          const HSpace(space: ArkieMetrics.snug),
          Flexible(
            child: Text(
              error.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.caption.copyWith(color: context.arkieColors.textFaint),
            ),
          ),
          TextButton(
            onPressed: () async => await context.read<RCONCubit>().retryConnection(),
            child: const Text('Reconnect'),
          ),
        ],
      ),
      _ => const StatusLamp(state: LinkState.connecting),
    };

    final row = Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: ArkieMetrics.tight),
        child: line,
      ),
    );

    if (lastChecked == null) return row;

    return Tooltip(message: 'Last checked ${lastChecked.toFriendlyString()}', child: row);
  }
}

extension on DateTime {
  // If less than 24 hours ago, show time only.
  // If less than 1 hour ago, show minutes ago.
  // If less than 1 minute ago but > 30 seconds, show seconds ago.
  // If less than 30 seconds, show "just now".
  // Otherwise, show date only.
  String toFriendlyString() {
    final now = DateTime.now();
    final difference = now.difference(this);
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return 'at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } else {
      return '${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}/${year.toString().substring(2)}';
    }
  }
}
