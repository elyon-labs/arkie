import 'dart:async';
import 'dart:math';

import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/command_help.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/command_input/command_input_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/command_input/command_input_state.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/widgets/connection_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CommandInput extends HookWidget {
  const CommandInput({super.key});

  @override
  Widget build(BuildContext context) {
    final connection = context.select((RCONCubit cubit) => cubit.state.connection);
    final hasConnection = connection is Loaded<RCONConnection>;

    return switch (connection) {
      Loaded<RCONConnection>(:final value) => BlocProvider(
        create: (context) => CommandInputCubit.create(connection: value),
        child: _View(hasConnection: hasConnection),
      ),
      _ => _View(hasConnection: hasConnection),
    };
  }
}

class _View extends StatefulWidget {
  const _View({required this.hasConnection});

  final bool hasConnection;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  OverlayEntry? _overlayEntry;
  final _textFieldKey = GlobalKey();
  final _focusNode = FocusNode();
  final _controller = TextEditingController();
  final _highlightedIndex = ValueNotifier<int?>(null);
  final _suggestions = ValueNotifier<List<CommandHelp>>([]);

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = [];

  Future<void> _sendCommand(String command) async {
    final cubit = context.read<RCONCubit>();
    await cubit.sendCommand(command);
    _controller.clear();
    _removeHighlightOverlay();
  }

  /// Called when the autocomplete overlay should be shown.
  ///
  /// This is when there are autocomplete suggestions available.
  void _showAutocompleteOverlay(List<CommandHelp> suggestions) {
    _removeHighlightOverlay();
    // Reverse the suggestions so that the most relevant ones are at the bottom
    _suggestions.value = suggestions.reversed.toList();
    _highlightedIndex.value = null;

    // Get the size and position of the text field
    final renderBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      canSizeOverlay: true,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;

        final maxHeightAboveTextField = offset.dy;

        return Positioned(
          left: offset.dx,
          bottom: screenSize.height - offset.dy,
          width: min(size.width, screenSize.width / 2),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeightAboveTextField - 20),
            child: Material(
              elevation: 4,
              child: SingleChildScrollView(
                controller: _scrollController,
                reverse: true,
                child: ValueListenableBuilder(
                  valueListenable: _highlightedIndex,
                  builder: (context, highlightedIndex, child) {
                    // Make sure we have a key for each suggestion
                    if (_itemKeys.length != _suggestions.value.length) {
                      _itemKeys
                        ..clear()
                        ..addAll(List.generate(_suggestions.value.length, (_) => GlobalKey()));
                    }

                    // After build, scroll to highlighted item (if any)
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      final index = highlightedIndex;
                      if (index == null) return;
                      if (index < 0 || index >= _itemKeys.length) return;

                      final ctx = _itemKeys[index].currentContext;
                      if (ctx != null) {
                        await Scrollable.ensureVisible(
                          ctx,
                          alignment: 0.5, // center-ish; tweak if you like
                          duration: const Duration(milliseconds: 100),
                        );
                      }
                    });

                    return Column(
                      children: List.generate(_suggestions.value.length, (index) {
                        final suggestion = _suggestions.value.elementAt(index);
                        final isSelected = _highlightedIndex.value == index;
                        return ListTile(
                          key: _itemKeys[index],
                          title: Text('${suggestion.name} ${isSelected ? "<" : ""}'),
                          selected: isSelected,
                          subtitle: Text(suggestion.description),
                          onTap: () {
                            final completion = suggestion.name;
                            _controller
                              ..text = completion
                              ..selection = TextSelection.collapsed(offset: completion.length);
                            _removeHighlightOverlay();
                          },
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Removes the autocomplete overlay if it exists.
  void _removeHighlightOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _highlightedIndex.value = null;
    _suggestions.value = [];
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeHighlightOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build the TextField first
    Widget textField = TextField(
      key: _textFieldKey,
      enabled: widget.hasConnection,
      controller: _controller,
      cursorHeight: context.sizes.unit * 2,
      cursorWidth: context.sizes.unit,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: 'Enter RCON command',
        border: InputBorder.none,
        hintStyle: context.text.caption,
      ),
      onChanged: (text) {
        // Only try to call the cubit when we *know* we have a connection.
        if (!widget.hasConnection) return;

        // Safe: this branch only runs when the cubit is actually provided.
        unawaited(context.read<CommandInputCubit>().onInputChanged(text));
      },
    );

    // When connected, wrap the TextField in a BlocListener
    if (widget.hasConnection) {
      textField = BlocListener<CommandInputCubit, CommandInputState>(
        listener: (context, state) {
          if (state.autoCompleteCommands.isNotEmpty && _controller.text.isNotEmpty) {
            _showAutocompleteOverlay(state.autoCompleteCommands);
          } else {
            _removeHighlightOverlay();
          }
        },
        child: textField,
      );
    }

    return Column(
      children: [
        Focus(
          focusNode: _focusNode,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;

            // ESC → close overlay, keep focus in the field
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              _removeHighlightOverlay();
              return KeyEventResult.handled;
            }

            // TAB → apply completion from your suggestion list, but don't submit
            if (event.logicalKey == LogicalKeyboardKey.tab) {
              final highlightedIndex = _highlightedIndex.value;
              if (highlightedIndex != null &&
                  highlightedIndex >= 0 &&
                  highlightedIndex < _suggestions.value.length) {
                final suggestion = _suggestions.value[highlightedIndex];
                final completion = suggestion.name;
                _controller
                  ..text = completion
                  ..selection = TextSelection.collapsed(offset: completion.length);

                _removeHighlightOverlay();

                return KeyEventResult.handled;
              }
            }

            // ENTER → submit command (with highlighted suggestion if any)
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              // If we have a highlighted suggestion, use that
              final highlightedIndex = _highlightedIndex.value;
              if (highlightedIndex != null &&
                  highlightedIndex >= 0 &&
                  highlightedIndex < _suggestions.value.length) {
                final suggestion = _suggestions.value[highlightedIndex];
                final completion = suggestion.name;
                _controller
                  ..text = completion
                  ..selection = TextSelection.collapsed(offset: completion.length);

                _removeHighlightOverlay();
                return KeyEventResult.handled;
              }

              // Otherwise, submit the command as-is
              unawaited(_sendCommand(_controller.text));
              return KeyEventResult.handled;
            }

            // UP/DOWN → move highlight in overlay
            if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                event.logicalKey == LogicalKeyboardKey.arrowDown) {
              if (_suggestions.value.isEmpty) return KeyEventResult.handled;

              final lastIndex = _suggestions.value.length - 1;
              final current = _highlightedIndex.value;

              _highlightedIndex.value = switch ((current, event.logicalKey)) {
                // Nothing selected yet
                (null, LogicalKeyboardKey.arrowUp) => lastIndex, // start from bottom
                (null, LogicalKeyboardKey.arrowDown) => 0, // start from top
                // Already have a selection
                (final index, LogicalKeyboardKey.arrowUp) =>
                  index! > 0 ? index - 1 : 0, // clamp at top
                (final index, LogicalKeyboardKey.arrowDown) =>
                  index! < lastIndex ? index + 1 : lastIndex, // clamp at bottom

                _ => current,
              };

              return KeyEventResult.handled;
            }

            // Everything else → let TextField handle it normally
            return KeyEventResult.ignored;
          },
          child: textField,
        ),
        const ConnectionIndicator(),
      ],
    );
  }
}
