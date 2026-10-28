import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:dart_foundation/dart_foundation.dart' as app_async;
import 'package:flutter/material.dart';

class ConnectionPill extends StatelessWidget {
  const ConnectionPill({super.key, required this.connection});

  final app_async.Async<RCONConnection> connection;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (connection) {
      app_async.Loaded<RCONConnection>() => ('LIVE', context.colors.good),
      app_async.Error<RCONConnection>() => ('OFFLINE', context.colors.error),
      _ => ('CONNECTING', context.colors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const HSpace(space: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
