import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_mobile/features/rcon/presentation/server_chat_page.dart';
import 'package:arkie_mobile/features/servers/presentation/widgets/server_actions_sheet.dart';
import 'package:arkie_mobile/features/servers/presentation/widgets/server_list_tile.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

/// Every server in one pane, divided by hairlines.
///
/// A card each would make the list look like more things than it is; the pane
/// says these are one set, and the count in its border says how many.
class ServerList extends StatelessWidget {
  const ServerList({super.key, required this.servers});

  final List<Server> servers;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ArkieMetrics.edge,
        ArkieMetrics.loose,
        ArkieMetrics.edge,
        ArkieMetrics.section,
      ),
      children: [
        TerminalPanel(
          label: 'servers',
          padding: EdgeInsets.zero,
          trailing: Text(
            '${servers.length}',
            style: context.text.caption.copyWith(color: context.colors.muted),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, server) in servers.indexed) ...[
                if (index > 0) const Divider(),
                ServerListTile(
                  server: server,
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: (_) => ServerChatPage(server: server))),
                  onLongPress: () async => await showServerActionsSheet(context, server),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
