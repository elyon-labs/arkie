import 'package:arkie_core/features/rcon/data/api/messages_api.dart';
import 'package:arkie_core/features/rcon/data/api/saved_messages_api.dart';
import 'package:arkie_core/features/rcon/data/repository/messages_repository.dart';
import 'package:arkie_core/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_mobile/features/rcon/presentation/server_tools/server_tools_sheet.dart';
import 'package:arkie_mobile/features/rcon/presentation/widgets/command_composer.dart';
import 'package:arkie_mobile/features/rcon/presentation/widgets/connection_error_banner.dart';
import 'package:arkie_mobile/features/rcon/presentation/widgets/message_list.dart';
import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:dart_foundation/dart_foundation.dart' as app_async;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServerChatPage extends StatelessWidget {
  const ServerChatPage({super.key, required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => MessagesRepository(api: MessagesApi.create(), server: server),
        ),
        RepositoryProvider(
          create: (_) => SavedMessagesRepository(api: SavedMessagesApi.create(), server: server),
        ),
      ],
      child: BlocProvider<RCONCubit>(
        create: (context) => RCONCubit.create(context: context, server: server),
        child: _ServerChatView(server: server),
      ),
    );
  }
}

class _ServerChatView extends StatelessWidget {
  const _ServerChatView({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    final connection = context.select((RCONCubit cubit) => cubit.state.connection);
    final scaffold = _ServerChatScaffold(server: server);

    return switch (connection) {
      app_async.Loaded<RCONConnection>(:final value) => BlocProvider<ServerInfoCubit>(
        create: (_) => ServerInfoCubit.create(connection: value),
        child: scaffold,
      ),
      _ => scaffold,
    };
  }
}

class _ServerChatScaffold extends StatelessWidget {
  const _ServerChatScaffold({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    final messages = context.select((RCONCubit cubit) => cubit.state.messages);
    final savedMessages = context.select((RCONCubit cubit) => cubit.state.savedMessages);
    final connection = context.select((RCONCubit cubit) => cubit.state.connection);

    final link = switch (connection) {
      app_async.Loaded<RCONConnection>() => LinkState.live,
      app_async.Error<RCONConnection>() => LinkState.offline,
      _ => LinkState.connecting,
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(context.icons.back),
          tooltip: 'Back to servers',
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(server.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              '${server.address}:${server.port}',
              style: context.text.caption.copyWith(color: context.arkieColors.textFaint),
            ),
          ],
        ),
        actions: [
          StatusLamp(state: link),
          const HSpace(space: ArkieMetrics.snug),
          IconButton(
            onPressed: () async {
              await showServerToolsSheet(context);
            },
            icon: Icon(context.icons.grid),
            tooltip: 'Commands, maps, and players',
          ),
          const HSpace(space: ArkieMetrics.tight),
        ],
      ),
      body: Column(
        children: [
          if (connection case app_async.Error<RCONConnection>(:final error))
            ConnectionErrorBanner(error: error.toString()),
          Expanded(
            child: MessageList(messages: messages, savedMessages: savedMessages),
          ),
          const CommandComposer(),
        ],
      ),
    );
  }
}
