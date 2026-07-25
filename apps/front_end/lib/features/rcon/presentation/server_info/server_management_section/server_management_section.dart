import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_management_section/server_management_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_management_section/server_management_state.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/edit_server_management_dialog/edit_server_management_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServerManagementSection extends StatelessWidget {
  const ServerManagementSection({super.key, required this.server, this.cubit});

  final Server server;
  final ServerManagementCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final config = server.managementConfig;
    if (config == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.sizes.unit),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Server process management is not configured for this server.'),
            TextButton(
              onPressed: () => _openEditor(context, server),
              child: const Text('Configure'),
            ),
          ],
        ),
      );
    }

    final cubit = this.cubit;
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit,
        child: _ServerManagementView(server: server),
      );
    }
    return BlocProvider(
      create: (_) => ServerManagementCubit.create(config: config),
      child: _ServerManagementView(server: server),
    );
  }
}

class _ServerManagementView extends StatelessWidget {
  const _ServerManagementView({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServerManagementCubit, ServerManagementState>(
      builder: (context, state) {
        final cubit = context.read<ServerManagementCubit>();
        return Padding(
          padding: EdgeInsets.symmetric(vertical: context.sizes.unit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: context.sizes.unit,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Server process', style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    onPressed: state.isBusy ? null : () => _openEditor(context, server),
                    child: const Text('Edit'),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: context.sizes.unit,
                children: [
                  Visibility(
                    visible: false,
                    child: ElevatedButton(
                      onPressed: state.isBusy ? null : cubit.start,
                      child: const Text('Start'),
                    ),
                  ),
                  Visibility(
                    visible: false,
                    child: ElevatedButton(
                      onPressed: state.isBusy ? null : cubit.stop,
                      child: const Text('Stop'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: state.isBusy ? null : cubit.restart,
                    child: const Text('Restart'),
                  ),
                  ElevatedButton(
                    onPressed: cubit.toggleLogs,
                    child: Text(state.isStreamingLogs ? 'Stop logs' : 'Stream logs'),
                  ),
                ],
              ),
              if (state.status != null) Text(state.status!),
              if (state.logs.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 240),
                  padding: EdgeInsets.all(context.sizes.unit),
                  color: context.colors.background,
                  child: SingleChildScrollView(
                    reverse: true,
                    child: SelectableText(state.logs.join('\n')),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _openEditor(BuildContext context, Server server) async {
  final messenger = ScaffoldMessenger.of(context);
  final warning = await EditServerManagementDialog.show(context, server);
  if (warning != null && warning.isNotEmpty) {
    messenger.showSnackBar(SnackBar(content: Text(warning)));
  }
}
