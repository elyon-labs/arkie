import 'dart:async';

import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/core/async.dart' as app_async;
import 'package:cs2_rcon_front_end/features/rcon/data/api/messages_api.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/api/saved_messages_api.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/messages_repository.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/change_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:oxidized/oxidized.dart';

const _background = Color(0xFF0E1014);
const _surface = Color(0xFF171A21);
const _surfaceElevated = Color(0xFF202530);
const _accent = Color(0xFFBB86FC);

class MobileApp extends StatelessWidget {
  const MobileApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arkie',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: home ?? const ServersPage(),
    );
  }
}

ThemeData _buildTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: _accent, brightness: Brightness.dark)
      .copyWith(
        surface: _background,
        surfaceContainer: _surface,
        surfaceContainerHigh: _surfaceElevated,
        primary: _accent,
        onPrimary: Colors.black,
      );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: _background,
    useMaterial3: true,
    fontFamily: 'monospace',
    appBarTheme: const AppBarTheme(
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: _surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: _accent),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

class ServersPage extends StatelessWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => ServersCubit.create(), child: const _ServersView());
  }
}

class _ServersView extends StatelessWidget {
  const _ServersView();

  @override
  Widget build(BuildContext context) {
    final servers = context.select((ServersCubit cubit) => cubit.state.servers);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Arkie', style: TextStyle(fontWeight: FontWeight.w800)),
            Text(
              'YOUR SERVERS',
              style: TextStyle(fontSize: 11, letterSpacing: 1.8, color: Colors.white54),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Arkie',
              applicationVersion: 'Mobile preview',
              applicationLegalese: 'RCON console for Counter-Strike 2 servers.',
            ),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About Arkie',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: servers.isEmpty ? const _EmptyServerList() : _ServerList(servers: servers),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _showAddServerSheet(context);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add server'),
      ),
    );
  }
}

class _ServerList extends StatelessWidget {
  const _ServerList({required this.servers});

  final List<Server> servers;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      itemCount: servers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final server = servers[index];
        return _ServerListTile(
          server: server,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => ServerChatPage(server: server))),
        );
      },
    );
  }
}

class _ServerListTile extends StatelessWidget {
  const _ServerListTile({required this.server, required this.onTap});

  final Server server;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: Text(
                  _serverInitials(server.name),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${server.address}:${server.port}',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tap to open console',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyServerList extends StatelessWidget {
  const _EmptyServerList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 128),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.dns_rounded, size: 42, color: colorScheme.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your server list is quiet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Add a CS2 server to keep its RCON console, saved commands, and maps one tap away.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                await _showAddServerSheet(context);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your first server'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAddServerSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider(
      create: (_) => AddServerDialogCubit.create(),
      child: const _AddServerSheetBody(),
    ),
  );
}

class _AddServerSheetBody extends HookWidget {
  const _AddServerSheetBody();

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final addressController = useTextEditingController();
    final portController = useTextEditingController(text: '27015');
    final passwordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final state = context.watch<AddServerDialogCubit>().state;
    final isSaving = state.addServerResult.isLoading;
    final errorText = switch (state.addServerResult) {
      app_async.Error(:final error) => error.toString(),
      _ => null,
    };

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: Form(
          key: formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Add a server',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Arkie will verify the RCON connection before saving it.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: nameController,
                enabled: !isSaving,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Server name'),
                onChanged: context.read<AddServerDialogCubit>().setName,
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressController,
                enabled: !isSaving,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Address or hostname'),
                onChanged: context.read<AddServerDialogCubit>().setAddress,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter an address' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: portController,
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Port'),
                onChanged: (value) =>
                    context.read<AddServerDialogCubit>().setPort(int.tryParse(value) ?? -1),
                validator: (value) {
                  final port = int.tryParse(value ?? '');
                  return port == null || port < 1 || port > 65535 ? 'Enter a valid port' : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                enabled: !isSaving,
                obscureText: true,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'RCON password'),
                onChanged: context.read<AddServerDialogCubit>().setPassword,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter the RCON password' : null,
              ),
              if (errorText != null) ...[
                const SizedBox(height: 14),
                Text(errorText, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (formKey.currentState?.validate() ?? false) {
                          await context.read<AddServerDialogCubit>().saveServer();
                          if (!context.mounted) return;
                          final result = context.read<AddServerDialogCubit>().state.addServerResult;
                          if (result case app_async.Loaded<Result<Server, String>>(
                            :final value,
                          ) when value.isOk()) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                child: Text(isSaving ? 'Connecting…' : 'Save server'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      child: BlocProvider(
        create: (context) => RCONCubit.create(context: context, server: server),
        child: _ServerChatView(server: server),
      ),
    );
  }
}

class _ServerChatView extends HookWidget {
  const _ServerChatView({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    final composerController = useTextEditingController();
    final messages = context.select((RCONCubit cubit) => cubit.state.messages);
    final savedMessages = context.select((RCONCubit cubit) => cubit.state.savedMessages);
    final connection = context.select((RCONCubit cubit) => cubit.state.connection);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to servers',
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(server.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              '${server.address}:${server.port}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11),
            ),
          ],
        ),
        actions: [
          _ConnectionPill(connection: connection),
          IconButton(
            onPressed: () async {
              await _showServerTools(context);
            },
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Commands and maps',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          if (connection case app_async.Error<RCONConnection>(:final error))
            _ConnectionErrorBanner(error: error.toString()),
          Expanded(
            child: _MessageList(messages: messages, savedMessages: savedMessages),
          ),
          _CommandComposer(
            controller: composerController,
            onSend: () => _sendComposerCommand(context, composerController),
          ),
        ],
      ),
    );
  }
}

class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({required this.connection});

  final app_async.Async<RCONConnection> connection;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (connection) {
      app_async.Loaded<RCONConnection>() => ('LIVE', Colors.greenAccent),
      app_async.Error<RCONConnection>() => ('OFFLINE', Theme.of(context).colorScheme.error),
      _ => ('CONNECTING', Colors.amberAccent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ConnectionErrorBanner extends StatelessWidget {
  const _ConnectionErrorBanner({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: colorScheme.onErrorContainer, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 11),
            ),
          ),
          TextButton(
            onPressed: () => context.read<RCONCubit>().retryConnection(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends HookWidget {
  const _MessageList({required this.messages, required this.savedMessages});

  final List<Message> messages;
  final List<SavedMessage> savedMessages;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    useEffect(() {
      if (!scrollController.hasClients) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          unawaited(
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            ),
          );
        }
      });
      return null;
    }, [messages.length]);

    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.terminal_rounded, size: 34, color: Colors.white38),
              SizedBox(height: 14),
              Text('No command traffic yet', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 6),
              Text(
                'Send a command below to start a conversation with the server.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final message = messages[index];
        SavedMessage? savedMessage;
        for (final saved in savedMessages) {
          if (saved.body.trim() == message.body.trim()) {
            savedMessage = saved;
            break;
          }
        }
        return _MessageBubble(message: message, savedMessage: savedMessage);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.savedMessage});

  final Message message;
  final SavedMessage? savedMessage;

  @override
  Widget build(BuildContext context) {
    final isClient = message.sender == Sender.client;
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isClient
            ? () async {
                await _showMessageActions(context);
              }
            : null,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.84),
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
          decoration: BoxDecoration(
            color: isClient ? colorScheme.primaryContainer : _surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isClient ? 18 : 5),
              bottomRight: Radius.circular(isClient ? 5 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isClient ? Icons.arrow_upward_rounded : Icons.south_rounded,
                    size: 13,
                    color: isClient ? colorScheme.onPrimaryContainer : colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isClient ? 'COMMAND' : 'SERVER',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      color: isClient ? colorScheme.onPrimaryContainer : colorScheme.primary,
                    ),
                  ),
                  if (savedMessage != null) ...[
                    const SizedBox(width: 7),
                    Icon(Icons.bookmark_rounded, size: 12, color: colorScheme.primary),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              SelectableText(
                message.bodyWithoutTerminalCharacter,
                style: TextStyle(
                  color: isClient ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMessageActions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.replay_rounded),
              title: const Text('Send again'),
              onTap: () async {
                await context.read<RCONCubit>().sendCommand(message.body);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                savedMessage == null ? Icons.bookmark_add_outlined : Icons.bookmark_remove_outlined,
              ),
              title: Text(savedMessage == null ? 'Save command' : 'Remove saved command'),
              onTap: () async {
                final cubit = context.read<RCONCubit>();
                if (savedMessage == null) {
                  await cubit.saveMessage(message);
                } else {
                  await cubit.unsaveMessage(savedMessage!);
                }
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CommandComposer extends StatelessWidget {
  const _CommandComposer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + MediaQuery.paddingOf(context).bottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) async {
                await onSend();
              },
              decoration: const InputDecoration(
                hintText: 'Enter an RCON command…',
                prefixIcon: Icon(Icons.chevron_right_rounded),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () async {
              await onSend();
            },
            icon: const Icon(Icons.arrow_upward_rounded),
            color: colorScheme.onPrimary,
            tooltip: 'Send command',
          ),
        ],
      ),
    );
  }
}

Future<void> _sendComposerCommand(BuildContext context, TextEditingController controller) async {
  final command = controller.text.trim();
  if (command.isEmpty) return;
  controller.clear();
  await context.read<RCONCubit>().sendCommand(command);
}

Future<void> _showServerTools(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ServerToolsSheet(pageContext: context),
  );
}

class _ServerToolsSheet extends StatelessWidget {
  const _ServerToolsSheet({required this.pageContext});

  final BuildContext pageContext;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.84,
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded),
                    SizedBox(width: 10),
                    Text(
                      'Server tools',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.bookmark_outline_rounded), text: 'Saved commands'),
                  Tab(icon: Icon(Icons.map_outlined), text: 'Maps'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    const _SavedCommandsTab(),
                    _MapsTab(pageContext: pageContext),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedCommandsTab extends StatelessWidget {
  const _SavedCommandsTab();

  @override
  Widget build(BuildContext context) {
    final savedMessages = context.select((RCONCubit cubit) => cubit.state.savedMessages);
    if (savedMessages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Saved commands will appear here. Long-press a command in the chat to save it.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, height: 1.5),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: savedMessages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final saved = savedMessages[index];
        return Material(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: const Icon(Icons.terminal_rounded),
            title: Text(saved.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(saved.body, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.play_arrow_rounded),
            onTap: () async {
              await context.read<RCONCubit>().sendCommand(saved.body);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}

class _MapsTab extends StatelessWidget {
  const _MapsTab({required this.pageContext});

  final BuildContext pageContext;

  @override
  Widget build(BuildContext context) {
    final maps = [...KnownMap.directory, ...WorkshopMap.directory];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: maps.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final map = maps[index];
        return Material(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: Icon(_mapIcon(map)),
            title: Text(map.displayName),
            subtitle: Text(map.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.arrow_forward_rounded),
            onTap: () => _changeMap(context, map),
          ),
        );
      },
    );
  }

  Future<void> _changeMap(BuildContext context, CS2Map map) async {
    final connection = context.read<RCONCubit>().state.connection;
    if (connection is! app_async.Loaded<RCONConnection>) {
      ScaffoldMessenger.of(
        pageContext,
      ).showSnackBar(const SnackBar(content: Text('Connect to the server before changing maps.')));
      return;
    }
    final result = await ChangeMap.create(connection: connection.value)(map);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    if (result.isErr()) {
      ScaffoldMessenger.of(
        pageContext,
      ).showSnackBar(const SnackBar(content: Text('The server rejected the map change.')));
    }
  }

  IconData _mapIcon(CS2Map map) {
    return switch (map.type) {
      CS2MapType.defusal => Icons.shield_outlined,
      CS2MapType.hostageRescue => Icons.home_work_outlined,
      CS2MapType.armsRace => Icons.bolt_outlined,
      CS2MapType.other => Icons.public_rounded,
    };
  }
}

String _serverInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final namePart = parts.first;
    return namePart.substring(0, namePart.length.clamp(1, 2)).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
}
