import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/player_info.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/models/_duration.dart';

sealed class PendingAction {
  const PendingAction();

  String get description;
}

final class PendingKick extends PendingAction {
  const PendingKick(this.player);

  final PlayerInfo player;

  @override
  String get description => 'Kicking ${player.displayName}';
}

final class PendingBan extends PendingAction {
  const PendingBan(this.player, {required this.duration});

  final PlayerInfo player;
  final Duration duration;

  @override
  String get description => 'Banning ${player.displayName} (${duration.banDescription})';
}

final class PendingMapChange extends PendingAction {
  const PendingMapChange(this.map);

  final CS2Map map;

  @override
  String get description => 'Changing map to ${map.name}';
}
