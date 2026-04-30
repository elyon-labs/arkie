import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:flutter/services.dart';
import 'package:oxidized/src/result.dart';

class FakeRCONConnection implements RCONConnection {
  const FakeRCONConnection({this.onClose, this.onSendCommand});

  final VoidCallback? onClose;
  final SendCommand? onSendCommand;

  @override
  Future<void> close() {
    onClose?.call();
    return Future.value();
  }

  @override
  Future<Result<RCONServerPacket, Exception>> sendCommand(String command) async {
    return onSendCommand?.call(command) ?? Ok(RCONServerPacket.responseValue(id: 1, body: 'OK'));
  }
}
