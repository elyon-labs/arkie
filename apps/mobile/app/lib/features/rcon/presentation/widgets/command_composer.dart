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

/// The prompt at the foot of the console. While connected, typing shows the
/// matching commands (from the server's own `find`) above it; tapping one
/// sends it immediately.
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final arkie = context.arkieColors;

    final prompt = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: arkie.border, width: ArkieMetrics.hairline),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ArkieMetrics.edge,
          ArkieMetrics.tight,
          ArkieMetrics.tight,
          ArkieMetrics.tight + MediaQuery.paddingOf(context).bottom,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: ArkieMetrics.snug),
              child: Text(
                '>',
                style: context.text.body.copyWith(
                  color: widget.hasConnection ? colors.accent : arkie.textFaint,
                ),
              ),
            ),
            const HSpace(space: ArkieMetrics.tight),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.hasConnection,
                minLines: 1,
                maxLines: 4,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.send,
                style: context.text.body,
                // A block cursor, the width of the characters it sits between.
                cursorWidth: 8,
                cursorRadius: Radius.zero,
                cursorColor: colors.accent,
                decoration: const InputDecoration(
                  hintText: 'rcon command',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: ArkieMetrics.snug),
                ),
                onChanged: (text) {
                  if (!widget.hasConnection) return;
                  unawaited(context.read<CommandInputCubit>().onInputChanged(text));
                },
                onSubmitted: (text) async => await _sendCommand(text),
              ),
            ),
            IconButton(
              onPressed: widget.hasConnection
                  ? () async => await _sendCommand(_controller.text)
                  : null,
              icon: Icon(context.icons.send),
              tooltip: 'Send command',
            ),
          ],
        ),
      ),
    );

    if (!widget.hasConnection) return prompt;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<CommandInputCubit, CommandInputState>(
          builder: (context, state) {
            if (state.autoCompleteCommands.isEmpty) return const SizedBox.shrink();
            return _SuggestionsList(
              suggestions: state.autoCompleteCommands,
              onSelect: (suggestion) async => await _sendCommand(suggestion.name),
            );
          },
        ),
        prompt,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ArkieMetrics.edge,
        0,
        ArkieMetrics.edge,
        ArkieMetrics.snug,
      ),
      child: TerminalPanel(
        label: 'find',
        padding: EdgeInsets.zero,
        fill: context.colors.card,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: ArkieMetrics.gutter),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return InkWell(
                onTap: () => onSelect(suggestion),
                highlightColor: context.arkieColors.surfacePressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ArkieMetrics.snug,
                    vertical: ArkieMetrics.tight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.name,
                        style: context.text.body.copyWith(color: context.colors.accent),
                      ),
                      if (suggestion.description.isNotEmpty)
                        Text(
                          suggestion.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.caption.copyWith(
                            color: context.arkieColors.textFaint,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
