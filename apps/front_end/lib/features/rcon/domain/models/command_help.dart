/// A model representing help information for a command.
class CommandHelp {
  CommandHelp({required this.name, required this.description});

  /// The name of the command. This can actually be invoked as an RCON command.
  final String name;

  /// The description of the command. It may be empty.
  final String description;

  @override
  String toString() => '$name — $description';
}
