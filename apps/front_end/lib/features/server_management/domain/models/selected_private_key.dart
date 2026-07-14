import 'dart:typed_data';

class SelectedPrivateKey {
  SelectedPrivateKey({required this.displayName, required this.pemBytes});

  final String displayName;
  final Uint8List pemBytes;

  void clear() => pemBytes.fillRange(0, pemBytes.length);
}
