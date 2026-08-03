import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:flutter/material.dart';

class ServerManagementForm extends StatelessWidget {
  const ServerManagementForm({
    super.key,
    required this.sshHost,
    required this.sshPort,
    required this.sshUser,
    required this.hostKeyFingerprint,
    required this.privateKeyDisplayName,
    required this.isBusy,
    required this.isSelectingPrivateKey,
    required this.onSshHostChanged,
    required this.onSshPortChanged,
    required this.onSshUserChanged,
    required this.onHostKeyFingerprintChanged,
    required this.onSelectPrivateKey,
    this.privateKeyError,
  });

  final String sshHost;
  final int sshPort;
  final String sshUser;
  final String hostKeyFingerprint;
  final String? privateKeyDisplayName;
  final String? privateKeyError;
  final bool isBusy;
  final bool isSelectingPrivateKey;
  final ValueChanged<String> onSshHostChanged;
  final ValueChanged<int> onSshPortChanged;
  final ValueChanged<String> onSshUserChanged;
  final ValueChanged<String> onHostKeyFingerprintChanged;
  final VoidCallback onSelectPrivateKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: sshHost,
          enabled: !isBusy,
          onChanged: onSshHostChanged,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(labelText: 'SSH host'),
        ),
        SizedBox(height: context.sizes.unit),
        TextFormField(
          initialValue: '$sshPort',
          enabled: !isBusy,
          onChanged: (value) => onSshPortChanged(int.tryParse(value) ?? 0),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'SSH port'),
        ),
        SizedBox(height: context.sizes.unit),
        TextFormField(
          initialValue: sshUser,
          enabled: !isBusy,
          onChanged: onSshUserChanged,
          decoration: const InputDecoration(labelText: 'SSH user'),
        ),
        SizedBox(height: context.sizes.unit),
        Row(
          children: [
            Expanded(
              child: Text(
                privateKeyDisplayName ?? 'No private key selected',
                key: const Key('private-key-display-name'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: context.sizes.unit),
            OutlinedButton(
              key: const Key('select-private-key-button'),
              onPressed: isBusy ? null : onSelectPrivateKey,
              child: Text(
                isSelectingPrivateKey
                    ? 'Selecting...'
                    : privateKeyDisplayName == null
                    ? 'Select'
                    : 'Replace',
              ),
            ),
          ],
        ),
        if (privateKeyError case final error?) ...[
          SizedBox(height: context.sizes.unit / 2),
          Text(
            error,
            key: const Key('private-key-selection-error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        SizedBox(height: context.sizes.unit),
        TextFormField(
          initialValue: hostKeyFingerprint,
          enabled: !isBusy,
          onChanged: onHostKeyFingerprintChanged,
          decoration: const InputDecoration(labelText: 'Host key fingerprint (SHA256:...)'),
        ),
      ],
    );
  }
}
