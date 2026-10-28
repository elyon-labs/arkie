import 'package:arkie_core/features/rcon/data/models/message.dart';
import 'package:arkie_core/features/rcon/data/models/saved_message.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:hive_ce/hive.dart';

@GenerateAdapters([
  AdapterSpec<Server>(),
  AdapterSpec<Message>(),
  AdapterSpec<Sender>(),
  AdapterSpec<SavedMessage>(),
])
part 'hive_adapters.g.dart';
