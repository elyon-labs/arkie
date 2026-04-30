import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.select((RCONCubit cubit) => cubit.state);
    final lastConnectionCheckTime = state.lastConnectionCheckTime;
    final child = Padding(
      padding: EdgeInsets.symmetric(horizontal: context.sizes.unit / 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: switch (state.connection) {
          Loaded<RCONConnection>() => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, color: context.colors.good, size: context.sizes.unit * 1.5),
              const SizedBox(width: 8),
              Text('Connected', style: context.text.caption),
            ],
          ),
          Error<RCONConnection>(:final error) => Row(
            children: [
              Icon(Icons.error, color: context.colors.error),
              const SizedBox(width: 8),
              Flexible(child: Text(error.toString(), style: context.text.caption)),
              TextButton(
                onPressed: () async {
                  await context.read<RCONCubit>().retryConnection();
                },
                child: const Text('Reconnect'),
              ),
            ],
          ),
          _ => SizedBox.square(
            dimension: context.sizes.unit * 2,
            child: CircularProgressIndicator(strokeWidth: context.sizes.unit / 4),
          ),
        },
      ),
    );
    if (lastConnectionCheckTime != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Tooltip(
          message: 'Last checked: ${lastConnectionCheckTime.toFriendlyString()}',
          child: child,
        ),
      );
    } else {
      return child;
    }
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
