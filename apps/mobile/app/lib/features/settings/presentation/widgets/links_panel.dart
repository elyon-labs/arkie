import 'package:arkie_core/links.dart';
import 'package:arkie_mobile/core/widgets/tool_row.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Everything about Arkie that lives outside the app.
class LinksPanel extends StatelessWidget {
  const LinksPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const TerminalPanel(
      label: 'about',
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LinkRow(
            title: "What's new",
            subtitle: 'Release notes for every published version',
            url: ArkieLinks.whatsNew,
          ),
          Divider(),
          _LinkRow(
            title: 'Source code',
            subtitle: 'Arkie is open source on GitHub',
            url: ArkieLinks.repository,
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.title, required this.subtitle, required this.url});

  final String title;
  final String subtitle;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ToolRow(
      title: title,
      subtitle: subtitle,
      trailing: Icon(Icons.open_in_new, size: 16, color: context.colors.muted),
      onTap: () async => await launchUrl(Uri.parse(url)),
    );
  }
}
