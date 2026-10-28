import 'package:arkie_core/features/rcon/data/api/messages_api.dart';
import 'package:arkie_core/features/rcon/data/api/saved_messages_api.dart';
import 'package:arkie_core/features/rcon/data/repository/messages_repository.dart';
import 'package:arkie_core/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/core_ui/rounded_superellipse_box.dart';
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

class _Console extends StatelessWidget {
  const _Console({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return RoundedSuperellipseBox(
      color: context.colors.card,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MessagingWindow(server: server),
          const _ServerInfo(),
        ],
      ),
    );
  }
}

class _MessagingWindow extends StatelessWidget {
  const _MessagingWindow({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 5,
      child: Column(
        children: [
          const Expanded(child: Messages()),
          _CommandInput(server: server),
        ],
      ),
    );
  }
}

class _CommandInput extends StatelessWidget {
  const _CommandInput({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: Sizes.edgePadding,
        right: Sizes.edgePadding,
        bottom: Sizes.edgePadding,
      ),
      child: RoundedSuperellipseBox(
        color: context.colors.modal,
        child: Padding(
          padding: const EdgeInsets.only(left: Sizes.unit, right: Sizes.unit, bottom: Sizes.unit),
          child: CommandInput(key: ValueKey(server.id)),
        ),
      ),
    );
  }
}

class _ServerInfo extends StatelessWidget {
  const _ServerInfo();

  @override
  Widget build(BuildContext context) {
    return const Flexible(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.only(
          top: Sizes.edgePadding,
          bottom: Sizes.edgePadding,
          right: Sizes.edgePadding,
        ),
        child: ServerInfo(),
      ),
    );
  }
}
