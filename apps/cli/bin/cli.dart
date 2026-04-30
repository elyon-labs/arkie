import 'package:args/command_runner.dart';
import 'package:cs2_rcon_cli/src/commands/connect.dart';

void main(List<String> arguments) async {
  final commandRunner = CommandRunner('rcon', 'Interact with an rcon server')
    ..addCommand(Connect());
  await commandRunner.run(arguments);
}
