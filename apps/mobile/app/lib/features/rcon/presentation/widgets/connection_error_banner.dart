import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectionErrorBanner extends StatelessWidget {
  const ConnectionErrorBanner({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: colors.error, size: 19),
          const HSpace(space: 10),
          Expanded(
            child: Text(
              error,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.error, fontSize: 11),
            ),
          ),
          TextButton(
            onPressed: () => context.read<RCONCubit>().retryConnection(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
