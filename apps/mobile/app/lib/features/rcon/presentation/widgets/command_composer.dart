import 'dart:async';

import 'package:arkie_core/features/rcon/domain/models/command_help.dart';
import 'package:arkie_state/features/rcon/command_input/command_input_cubit.dart';
import 'package:arkie_state/features/rcon/command_input/command_input_state.dart';
import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:dart_foundation/dart_foundation.dart' as app_async;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The composer at the bottom of the server chat screen. While connected,
/// typing shows a tappable list of matching commands (from the server's own
/// `find` command) above the text field; tapping one sends it immediately.
class CommandComposer extends StatelessWidget {
  const CommandComposer({super.key});

  @override
  Widget build(BuildContext context) {
    final connection = context.select((RCONCubit cubit) => cubit.state.connection);

    return switch (connection) {
      app_async.Loaded<RCONConnection>(:final value) => BlocProvider(
        create: (_) => CommandInputCubit.create(connection: value),
        child: const _ComposerView(hasConnection: true),
      ),
      _ => const _ComposerView(hasConnection: false),
    };
  }
}

class _ComposerView extends StatefulWidget {
  const _ComposerView({required this.hasConnection});

  final bool hasConnection;

  @override
  State<_ComposerView> createState() => _ComposerViewState();
}

class _ComposerViewState extends State<_ComposerView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendCommand(String command) async {
    if (command.trim().isEmpty) return;
    _controller.clear();
    if (widget.hasConnection) {
      unawaited(context.read<CommandInputCubit>().onInputChanged(''));
    }
    await context.read<RCONCubit>().sendCommand(command.trim());
  }

  Future<void> _selectSuggestion(CommandHelp suggestion) async {
    await _sendCommand(suggestion.name);
  }

  @override
  Widget build(BuildContext context) {
    final composer = Padding(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + MediaQuery.paddingOf(context).bottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.hasConnection,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onChanged: (text) {
                if (!widget.hasConnection) return;
                unawaited(context.read<CommandInputCubit>().onInputChanged(text));
              },
              onSubmitted: (text) async {
                await _sendCommand(text);
              },
              decoration: const InputDecoration(
                hintText: 'Enter an RCON command…',
                prefixIcon: Icon(Icons.chevron_right_rounded),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              ),
            ),
          ),
          const HSpace(),
          IconButton.filled(
            onPressed: () async {
              await _sendCommand(_controller.text);
            },
            icon: Icon(context.icons.send),
            color: context.colors.onPrimary,
            tooltip: 'Send command',
          ),
        ],
      ),
    );

    if (!widget.hasConnection) {
      return composer;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<CommandInputCubit, CommandInputState>(
          builder: (context, state) {
            if (state.autoCompleteCommands.isEmpty) return const SizedBox.shrink();
            return _SuggestionsList(
              suggestions: state.autoCompleteCommands,
              onSelect: _selectSuggestion,
            );
          },
        ),
        composer,
      ],
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({required this.suggestions, required this.onSelect});

  final List<CommandHelp> suggestions;
  final ValueSetter<CommandHelp> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: context.colors.modal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.terminal_rounded, size: 18),
            title: Text(suggestion.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: suggestion.description.isEmpty
                ? null
                : Text(
                    suggestion.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
            trailing: const Icon(Icons.arrow_upward_rounded, size: 16),
            onTap: () => onSelect(suggestion),
          );
        },
      ),
    );
  }
}
