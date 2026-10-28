import 'package:arkie_core/features/rcon/data/api/messages_api.dart';
import 'package:arkie_core/features/rcon/data/api/saved_messages_api.dart';
import 'package:arkie_core/features/rcon/data/repository/messages_repository.dart';
import 'package:arkie_core/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/command_input/command_input.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/widgets/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RCON extends StatelessWidget {
  const RCON({super.key, required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => MessagesRepository(api: MessagesApi.create(), server: server),
        ),
        RepositoryProvider(
          create: (context) =>
              SavedMessagesRepository(api: SavedMessagesApi.create(), server: server),
        ),
      ],
      child: BlocProvider<RCONCubit>(
        create: (context) => RCONCubit.create(context: context, server: server),
        child: _Console(server: server),
      ),
    );
  }
}

/// Two panes side by side, the way a terminal is split: the console on the
/// left with the prompt beneath it, what the server is doing on the right.
class _Console extends StatelessWidget {
  const _Console({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 5,
          child: TerminalPanel(
            label: server.name,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const Expanded(child: Messages()),
                _Prompt(server: server),
              ],
            ),
          ),
        ),
        const HSpace(space: ArkieMetrics.snug),
        const Flexible(flex: 2, child: ServerInfo()),
      ],
    );
  }
}

class _Prompt extends StatelessWidget {
  const _Prompt({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.arkieColors.border, width: ArkieMetrics.hairline),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ArkieMetrics.snug),
        child: CommandInput(key: ValueKey(server.id)),
      ),
    );
  }
}
