import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

class ServerListTile extends StatelessWidget {
  const ServerListTile({super.key, required this.server, required this.onTap});

  final Server server;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: colors.selected,
                foregroundColor: colors.onSelected,
                child: Text(
                  _serverInitials(server.name),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const HSpace(space: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const VSpace(space: 5),
                    Text(
                      '${server.address}:${server.port}',
                      style: TextStyle(color: colors.muted, fontSize: 12),
                    ),
                    const VSpace(),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: colors.muted, shape: BoxShape.circle),
                        ),
                        const HSpace(space: 6),
                        Text(
                          'Tap to open console',
                          style: TextStyle(color: colors.muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

String _serverInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final namePart = parts.first;
    return namePart.substring(0, namePart.length.clamp(1, 2)).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
}
