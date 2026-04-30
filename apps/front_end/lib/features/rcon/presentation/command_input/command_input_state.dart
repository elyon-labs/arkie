import 'package:cs2_rcon_front_end/features/rcon/domain/models/command_help.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'command_input_state.mapper.dart';

@MappableClass()
class CommandInputState with CommandInputStateMappable {
  CommandInputState({required this.autoCompleteCommands});

  factory CommandInputState.initial() {
    return CommandInputState(autoCompleteCommands: []);
  }

  final List<CommandHelp> autoCompleteCommands;
}
