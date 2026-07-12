import 'dart:async';

import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/server_management_service.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ServerManagementSection extends HookWidget {
  const ServerManagementSection({super.key, required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    final config = server.managementConfig;
    final status = useState<String?>(null);
    final logs = useState<List<String>>([]);
    final logSubscription = useRef<StreamSubscription<String>?>(null);
    final isBusy = useState(false);

    useEffect(() => () => logSubscription.value?.cancel(), const []);

    if (config == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.sizes.unit),
        child: const Text('Server process management is not configured for this server.'),
      );
    }

    Future<void> runAction(ServerManagementAction action) async {
      isBusy.value = true;
      try {
        final output = await const ServerManagementService().run(config, action);
        status.value = output.isEmpty ? '${action.name} completed' : output;
      } catch (error) {
        status.value = 'Failed to ${action.name}: $error';
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> toggleLogs() async {
      if (logSubscription.value != null) {
        await logSubscription.value?.cancel();
        logSubscription.value = null;
        status.value = 'Log stream stopped';
        return;
      }
      logs.value = [];
      status.value = 'Streaming logs...';
      logSubscription.value = const ServerManagementService().streamLogs(config).listen(
        (line) => logs.value = [...logs.value.take(199), line],
        onError: (Object error) {
          status.value = 'Log stream failed: $error';
          logSubscription.value = null;
        },
        onDone: () => logSubscription.value = null,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sizes.unit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.sizes.unit,
        children: [
          Text('Server process', style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: context.sizes.unit,
            runSpacing: context.sizes.unit,
            children: [
              FilledButton(onPressed: isBusy.value ? null : () => runAction(ServerManagementAction.start), child: const Text('Start')),
              FilledButton(onPressed: isBusy.value ? null : () => runAction(ServerManagementAction.stop), child: const Text('Stop')),
              FilledButton(onPressed: isBusy.value ? null : () => runAction(ServerManagementAction.restart), child: const Text('Restart')),
              OutlinedButton(onPressed: toggleLogs, child: Text(logSubscription.value == null ? 'Stream logs' : 'Stop logs')),
            ],
          ),
          if (status.value != null) Text(status.value!),
          if (logs.value.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 240),
              padding: EdgeInsets.all(context.sizes.unit),
              color: context.colors.background,
              child: SingleChildScrollView(
                reverse: true,
                child: SelectableText(logs.value.join('\n')),
              ),
            ),
        ],
      ),
    );
  }
}
