import 'dart:async';

import 'package:cs2_rcon_client/cs2_rcon_client.dart' hide SendCommand;
import 'package:cs2_rcon_front_end/features/rcon/domain/find_command.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/command_help.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/command_input/command_input_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';

class CommandInputCubit extends Cubit<CommandInputState> {
  CommandInputCubit({required FindCommand findCommand, required RCONConnection connection})
    : _connection = connection,
      _findCommand = findCommand,
      super(CommandInputState.initial());

  factory CommandInputCubit.create({required RCONConnection connection}) {
    return CommandInputCubit(
      findCommand: FindCommand(connection: connection),
      connection: connection,
    );
  }

  final FindCommand _findCommand;
  final RCONConnection _connection;
  Timer? _debounceTimer;

  Future<Iterable<CommandHelp>> onInputChanged(String input) async {
    _debounceTimer?.cancel();
    final completer = Completer<Iterable<CommandHelp>>();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (input.isEmpty) {
        emit(state.copyWith(autoCompleteCommands: []));
        completer.complete(<CommandHelp>[]);
        return;
      }

      final commandsResult = await _findCommand(commandPart: input, connection: _connection);

      final commands = switch (commandsResult) {
        Ok(:final value) => List<CommandHelp>.from(value),
        Err() => <CommandHelp>[],
      };

      emit(state.copyWith(autoCompleteCommands: commands));

      completer.complete(commands);
    });

    return completer.future;
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
