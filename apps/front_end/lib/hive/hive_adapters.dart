import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:hive_ce/hive.dart';

@GenerateAdapters([
  AdapterSpec<Server>(),
  AdapterSpec<ServerManagementConfig>(),
  AdapterSpec<ServerManagementBackend>(),
  AdapterSpec<Message>(),
  AdapterSpec<Sender>(),
  AdapterSpec<SavedMessage>(),
])
part 'hive_adapters.g.dart';
