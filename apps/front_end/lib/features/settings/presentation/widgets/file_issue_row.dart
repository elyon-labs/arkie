import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileIssueRow extends StatelessWidget {
  const FileIssueRow({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('File an issue'),
      subtitle: const Text('Report bugs or suggest features on GitHub'),
      trailing: const Icon(Icons.open_in_new),
      onTap: () async {
        await launchUrl(Uri.parse('https://github.com/elyon-labs/arkie/issues/new/choose'));
      },
    );
  }
}
