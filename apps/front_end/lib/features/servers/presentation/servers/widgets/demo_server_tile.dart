import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_state/features/servers/servers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// The offer to save a demo server, for anyone who wants to see what Arkie does
/// before they have a CS2 server to point it at.
///
/// It takes itself away once the demo server is saved, because only one can be.
class DemoServerTile extends HookWidget {
  const DemoServerTile({super.key, required this.onAdded});

  /// Called with the demo server once it is saved.
  final ValueChanged<Server> onAdded;

  @override
  Widget build(BuildContext context) {
    final hasDemoServer = context.select((ServersCubit cubit) => cubit.state.hasDemoServer);
    final isAdding = useState(false);

    if (hasDemoServer) return const SizedBox.shrink();

    return ListTile(
      leading: const Icon(Icons.play_circle_outline),
      title: const Text('Try a demo server'),
      subtitle: const Text('Runs inside the app and answers like a real one.'),
      enabled: !isAdding.value,
      onTap: () async {
        isAdding.value = true;
        final server = await context.read<ServersCubit>().addDemoServer();
        if (!context.mounted) return;
        isAdding.value = false;
        if (server != null) onAdded(server);
      },
    );
  }
}
