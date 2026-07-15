import 'dart:convert';

import 'package:cs2_rcon_front_end/features/server_management/domain/select_ssh_private_key.dart';
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
  test('returns Ok(null) when selection is cancelled', () async {
    final select = SelectSshPrivateKey(openFile: () async => null);

    final result = await select();

    expect(result.isOk(), isTrue);
    expect(result.unwrap(), isNull);
  });

  test('returns a supported unencrypted key with only its name', () async {
    final select = _subjectFor(utf8.encode(_unencryptedPem), name: 'id_ed25519');

    final result = await select();

    expect(result.isOk(), isTrue);
    final selected = result.unwrap()!;
    expect(selected.displayName, 'id_ed25519');
    expect(utf8.decode(selected.pemBytes), _unencryptedPem);
  });

  test('returns Err for modern and legacy encrypted keys', () async {
    for (final pem in [_encryptedOpenSshPem, _encryptedLegacyPem]) {
      final result = await _subjectFor(utf8.encode(pem))();

      expect(result.isErr(), isTrue);
      expect(result.unwrapErr().message, contains('Encrypted private keys are not supported'));
    }
  });

  test('returns Err for malformed and unsupported key files', () async {
    final cases = <List<int>>[
      utf8.encode('not a key'),
      utf8.encode('-----BEGIN CERTIFICATE-----\nAA==\n-----END CERTIFICATE-----'),
    ];

    for (final bytes in cases) {
      final result = await _subjectFor(bytes)();

      expect(result.isErr(), isTrue);
    }
  });

  test('returns Err for an empty file', () async {
    final result = await _subjectFor(const [])();

    expect(result.isErr(), isTrue);
    expect(result.unwrapErr().message, contains('empty'));
  });

  test('does not expose a source path when reading fails', () async {
    const sourcePath = '/private/sentinel/id_ed25519';
    final select = SelectSshPrivateKey(openFile: () async => XFile(sourcePath));

    final result = await select();

    expect(result.isErr(), isTrue);
    expect(result.unwrapErr().message, isNot(contains(sourcePath)));
    expect(result.unwrapErr().message, contains('could not read'));
  });

  test('does not expose platform details when opening the picker fails', () async {
    const sourcePath = '/private/sentinel/id_ed25519';
    final select = SelectSshPrivateKey(
      openFile: () async => throw PlatformException(code: 'picker-failed', details: sourcePath),
    );

    final result = await select();

    expect(result.isErr(), isTrue);
    expect(result.unwrapErr().message, isNot(contains(sourcePath)));
    expect(result.unwrapErr().message, contains('could not open'));
  });

  test('normalizes unexpected dependency exceptions into Err', () async {
    final select = SelectSshPrivateKey(openFile: () async => throw Exception('unexpected'));

    final result = await select();

    expect(result.isErr(), isTrue);
    expect(result.unwrapErr().message, 'Arkie could not select the private key.');
  });
}

SelectSshPrivateKey _subjectFor(List<int> bytes, {String name = 'id_ed25519'}) {
  return SelectSshPrivateKey(
    openFile: () async => XFile.fromData(Uint8List.fromList(bytes), name: name, path: name),
  );
}
