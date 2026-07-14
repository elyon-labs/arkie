import 'dart:convert';
import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/ssh_private_key_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';

const _pem = '''-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBpPal4/3f/qxFl7ugsT3C5YguwYJy66BqZZfjbVrh/LwAAAKjvACB47wAg
eAAAAAtzc2gtZWQyNTUxOQAAACBpPal4/3f/qxFl7ugsT3C5YguwYJy66BqZZfjbVrh/Lw
AAAEDA7onKLSmNPmz6svkb0EGkIFPgSpTablugz25qALF4f2k9qXj/d/+rEWXu6CxPcLli
C7BgnLroGpll+NtWuH8vAAAAIWJyYW5kb250cmF1dG1hbm5AYnJhbmRvbnMtbWFjYm9vaw
ECAwQ=
-----END OPENSSH PRIVATE KEY-----''';

void main() {
  test('returns null when selection is cancelled', () async {
    final picker = SshPrivateKeyPicker(openFile: () async => null);
    expect(await picker.pick(), isNull);
  });

  test('accepts a supported unencrypted key and exposes only its name', () async {
    final picker = SshPrivateKeyPicker(
      openFile: () async => XFile.fromData(
        Uint8List.fromList(utf8.encode(_pem)),
        name: 'id_ed25519',
        path: 'id_ed25519',
      ),
    );
    final selected = await picker.pick();
    expect(selected?.displayName, 'id_ed25519');
    expect(utf8.decode(selected!.pemBytes), _pem);
  });

  test('rejects empty, malformed, and encrypted keys with actionable errors', () async {
    final cases = <List<int>>[
      [],
      utf8.encode('not a key'),
      utf8.encode('-----BEGIN ENCRYPTED PRIVATE KEY-----'),
    ];
    for (final bytes in cases) {
      final picker = SshPrivateKeyPicker(
        openFile: () async => XFile.fromData(Uint8List.fromList(bytes), name: 'key'),
      );
      expect(picker.pick(), throwsA(isA<PrivateKeySelectionException>()));
    }
  });
}
