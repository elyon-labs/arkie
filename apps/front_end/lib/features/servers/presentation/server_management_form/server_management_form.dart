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
    required this.onSshHostChanged,
    required this.onSshPortChanged,
    required this.onSshUserChanged,
    required this.onHostKeyFingerprintChanged,
    required this.onChoosePrivateKey,
    this.privateKeyError,
    this.keyRequired = false,
  });

  final String sshHost;
  final int sshPort;
  final String sshUser;
  final String hostKeyFingerprint;
  final String? privateKeyDisplayName;
  final String? privateKeyError;
  final bool keyRequired;
  final bool isBusy;
  final ValueChanged<String> onSshHostChanged;
  final ValueChanged<int> onSshPortChanged;
  final ValueChanged<String> onSshUserChanged;
  final ValueChanged<String> onHostKeyFingerprintChanged;
  final VoidCallback onChoosePrivateKey;

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
        OutlinedButton(
          onPressed: isBusy ? null : onChoosePrivateKey,
          child: Text(
            privateKeyDisplayName == null
                ? 'Choose private key'
                : '$privateKeyDisplayName  •  Replace',
          ),
        ),
        if (keyRequired && privateKeyDisplayName != null)
          const Text('This key must be replaced before management can be saved.'),
        if (privateKeyError != null)
          Text(privateKeyError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
