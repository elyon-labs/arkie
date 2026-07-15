import 'dart:convert';

import 'package:cs2_rcon_front_end/features/server_management/data/ssh_private_key_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _unencryptedPem = '''
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBpPal4/3f/qxFl7ugsT3C5YguwYJy66BqZZfjbVrh/LwAAAKjvACB47wAg
eAAAAAtzc2gtZWQyNTUxOQAAACBpPal4/3f/qxFl7ugsT3C5YguwYJy66BqZZfjbVrh/Lw
AAAEDA7onKLSmNPmz6svkb0EGkIFPgSpTablugz25qALF4f2k9qXj/d/+rEWXu6CxPcLli
C7BgnLroGpll+NtWuH8vAAAAIWJyYW5kb250cmF1dG1hbm5AYnJhbmRvbnMtbWFjYm9vaw
ECAwQ=
-----END OPENSSH PRIVATE KEY-----''';

const _encryptedOpenSshPem = '''
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAACmFlczI1Ni1jdHIAAAAGYmNyeXB0AAAAGAAAABCJkip1wT
Yk3UdTpIaeVnE+AAAAGAAAAAEAAAAzAAAAC3NzaC1lZDI1NTE5AAAAIC4y0v3MTF87HCpI
nspzul4UpQWh5nWXFPHUJlDq6y4gAAAAsERP9XQ5lSJrEMDWea0Th8jcFLEBflKeyKlzc1
Ly7whshJ0y1Eapm3xFYc1v+bUZw6S/nhWrc5cS3+OiPjCN735HLvvs+A3amEWkli8nHtjv
ThcEJaONk+/p9CgBYphJ2xBAS+RYGcMVhByJkyaoQR4NUY+USYKh/+rJy/sHvB77yNRoOe
jH0ETjqh9JaQNqEGdY/xnYBVyDMuCVrfTP4xYVJ0cXXdb27RQV5bjrVRoQ
-----END OPENSSH PRIVATE KEY-----''';

const _encryptedLegacyPem = '''
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-256-CBC,00000000000000000000000000000000

AA==
-----END RSA PRIVATE KEY-----''';

void main() {
  test('returns null when selection is cancelled', () async {
    final picker = SshPrivateKeyPicker(openFile: () async => null);

    expect(await picker.pick(), isNull);
  });

  test('accepts a supported unencrypted key and exposes only its name', () async {
    final picker = _pickerFor(utf8.encode(_unencryptedPem), name: 'id_ed25519');

    final selected = await picker.pick();

    expect(selected?.displayName, 'id_ed25519');
    expect(utf8.decode(selected!.pemBytes), _unencryptedPem);
  });

  test('clears selected key bytes', () async {
    final selected = await _pickerFor(utf8.encode(_unencryptedPem)).pick();

    selected!.clear();

    expect(selected.pemBytes, everyElement(0));
  });

  test('rejects modern and legacy encrypted keys with an actionable error', () async {
    for (final pem in [_encryptedOpenSshPem, _encryptedLegacyPem]) {
      await expectLater(
        _pickerFor(utf8.encode(pem)).pick(),
        throwsA(
          isA<PrivateKeySelectionException>().having(
            (error) => error.message,
            'message',
            contains('Encrypted private keys are not supported'),
          ),
        ),
      );
    }
  });

  test('rejects malformed and unsupported key files', () async {
    final cases = <List<int>>[
      utf8.encode('not a key'),
      utf8.encode('-----BEGIN CERTIFICATE-----\nAA==\n-----END CERTIFICATE-----'),
    ];

    for (final bytes in cases) {
      await expectLater(_pickerFor(bytes).pick(), throwsA(isA<PrivateKeySelectionException>()));
    }
  });

  test('rejects an empty file', () async {
    await expectLater(
      _pickerFor(const []).pick(),
      throwsA(
        isA<PrivateKeySelectionException>().having(
          (error) => error.message,
          'message',
          contains('empty'),
        ),
      ),
    );
  });

  test('does not expose a source path when reading fails', () async {
    const sourcePath = '/private/sentinel/id_ed25519';
    final picker = SshPrivateKeyPicker(openFile: () async => XFile(sourcePath));

    await expectLater(
      picker.pick(),
      throwsA(
        isA<PrivateKeySelectionException>()
            .having((error) => error.message, 'message', isNot(contains(sourcePath)))
            .having((error) => error.message, 'message', contains('could not read')),
      ),
    );
  });

  test('does not expose platform details when opening the picker fails', () async {
    const sourcePath = '/private/sentinel/id_ed25519';
    final picker = SshPrivateKeyPicker(
      openFile: () async => throw PlatformException(code: 'picker-failed', details: sourcePath),
    );

    await expectLater(
      picker.pick(),
      throwsA(
        isA<PrivateKeySelectionException>()
            .having((error) => error.message, 'message', isNot(contains(sourcePath)))
            .having((error) => error.message, 'message', contains('could not open')),
      ),
    );
  });
}

SshPrivateKeyPicker _pickerFor(List<int> bytes, {String name = 'id_ed25519'}) {
  return SshPrivateKeyPicker(
    openFile: () async => XFile.fromData(Uint8List.fromList(bytes), name: name, path: name),
  );
}
