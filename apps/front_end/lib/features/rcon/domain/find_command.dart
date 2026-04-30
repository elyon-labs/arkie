import 'package:cs2_rcon_client/cs2_rcon_client.dart' hide SendCommand;
import 'package:cs2_rcon_front_end/features/rcon/domain/models/command_help.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:oxidized/oxidized.dart';

class FindCommand {
  FindCommand({required RCONConnection connection}) : _connection = connection;

  final RCONConnection _connection;

  Future<Result<List<CommandHelp>, Exception>> call({
    required String commandPart,
    required RCONConnection connection,
  }) async {
    // Send the 'find' command to the server to get matching commands
    final result = await _connection.sendCommand('find $commandPart');

    return result.andThen((packet) {
      final commandHelps = parseFindOutput(packet.body);

      // Only show the top 25 matches using fuzzy matching
      final scoredCommands =
          commandHelps.map((ch) => MapEntry(ch, ratio(commandPart, ch.name))).toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      return Ok(scoredCommands.take(25).map((e) => e.key).toList());
    });
  }
}

List<CommandHelp> parseFindOutput(String output) {
  final lines = output.split('\n');

  // 1. Find header line with "help text"
  final headerIndex = lines.indexWhere((l) => l.contains('help text'));
  if (headerIndex == -1) return [];

  final header = lines[headerIndex];

  // 2. Column where help text starts
  final helpCol = header.indexOf('help text');
  if (helpCol == -1) return [];

  // 3. Skip header and underline row
  // headerIndex: header
  // headerIndex + 1: "__________"
  final dataStart = headerIndex + 2;

  final results = <CommandHelp>[];
  CommandHelp? current;

  for (var i = dataStart; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isEmpty) continue;

    // Left side = everything before helpCol (name, value, flags, etc.)
    final left = helpCol <= line.length ? line.substring(0, helpCol) : line;
    // Right side = the help text column
    final right = helpCol < line.length ? line.substring(helpCol).trimRight() : '';

    final leftTrimmed = left.trimRight();

    if (leftTrimmed.trim().isEmpty) {
      // 4. Continuation line (wrapped help text)
      if (current != null && right.trim().isNotEmpty) {
        current = CommandHelp(
          name: current.name,
          description: '${current.description} ${right.trim()}'.trim(),
        );
        results[results.length - 1] = current;
      }
      continue;
    }

    // 5. New command row
    final name = leftTrimmed.trimLeft().split(RegExp(r'\s+')).first;
    final description = right.trim();

    current = CommandHelp(name: name, description: description);
    results.add(current);
  }

  return results;
}
