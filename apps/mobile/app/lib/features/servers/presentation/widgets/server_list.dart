import 'package:arkie_mobile/features/rcon/presentation/server_chat_page.dart';
import 'package:arkie_mobile/features/servers/presentation/widgets/server_list_tile.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:flutter/material.dart';

class ServerList extends StatelessWidget {
  const ServerList({super.key, required this.servers});

  final List<Server> servers;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      itemCount: servers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final server = servers[index];
        return ServerListTile(
          server: server,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => ServerChatPage(server: server))),
        );
      },
    );
  }
}
