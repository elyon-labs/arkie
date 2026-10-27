import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectionErrorBanner extends StatelessWidget {
  const ConnectionErrorBanner({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: colorScheme.onErrorContainer, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 11),
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
