import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

/// One server as a line in the servers pane: name over its address, with the
/// address in the faint tone so a column of them does not compete with the names.
class ServerListTile extends StatelessWidget {
  const ServerListTile({
    super.key,
    required this.server,
    required this.onTap,
    required this.onLongPress,
  });

  final Server server;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      highlightColor: context.arkieColors.surfacePressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ArkieMetrics.edge,
          vertical: ArkieMetrics.snug,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              server.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.body,
            ),
            Row(
              children: [
                Flexible(
                  child: Text(
                    '${server.address}:${server.port}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.caption.copyWith(color: context.arkieColors.textFaint),
                  ),
                ),
                if (server.isDemo) ...[
                  const HSpace(space: ArkieMetrics.tight),
                  Text('demo', style: context.text.caption.copyWith(color: context.colors.accent)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
