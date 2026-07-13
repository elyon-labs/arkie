import 'dart:async';

import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/restart_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/start_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/stop_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/watch_server_logs.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:oxidized/oxidized.dart';

class ServerManagementSection extends HookWidget {
  const ServerManagementSection({super.key, required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    final config = server.managementConfig;
    final status = useState<String?>(null);
    final logs = useState<List<String>>([]);
    final logSubscription = useRef<StreamSubscription<Result<String, Exception>>?>(null);
    final isBusy = useState(false);
    final startServer = useMemoized(StartServer.create);
    final stopServer = useMemoized(StopServer.create);
    final restartServer = useMemoized(RestartServer.create);
    final watchServerLogs = useMemoized(WatchServerLogs.create);

    useEffect(
      () =>
          () => logSubscription.value?.cancel(),
      const [],
    );

    if (config == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.sizes.unit),
        child: const Text('Server process management is not configured for this server.'),
      );
    }

    Future<void> runAction({
      required String name,
      required Future<Result<String, Exception>> Function() run,
    }) async {
      isBusy.value = true;
      try {
        final result = await run();
        status.value = result.when(
          ok: (output) => output.isEmpty ? '$name completed' : output,
          err: (error) => 'Failed to $name: $error',
        );
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
      logSubscription.value = watchServerLogs(config).listen((result) {
        result.when(
          ok: (line) => logs.value = [...logs.value.take(199), line],
          err: (error) => status.value = 'Log stream failed: $error',
        );
      }, onDone: () => logSubscription.value = null);
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
              FilledButton(
                onPressed: isBusy.value
                    ? null
                    : () => runAction(name: 'start', run: () => startServer(config)),
                child: const Text('Start'),
              ),
              FilledButton(
                onPressed: isBusy.value
                    ? null
                    : () => runAction(name: 'stop', run: () => stopServer(config)),
                child: const Text('Stop'),
              ),
              FilledButton(
                onPressed: isBusy.value
                    ? null
                    : () => runAction(name: 'restart', run: () => restartServer(config)),
                child: const Text('Restart'),
              ),
              OutlinedButton(
                onPressed: toggleLogs,
                child: Text(logSubscription.value == null ? 'Stream logs' : 'Stop logs'),
              ),
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
