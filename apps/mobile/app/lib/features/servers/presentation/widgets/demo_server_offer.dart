import 'package:arkie_state/features/servers/servers_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// The offer to save a demo server, for anyone who wants to see what Arkie does
/// before they have a CS2 server to point it at.
///
/// It takes itself away once the demo server is saved, because only one can be.
class DemoServerOffer extends HookWidget {
  const DemoServerOffer({super.key, this.onAdded});

  /// Called once the demo server is saved, for whoever needs to close up behind
  /// it.
  final VoidCallback? onAdded;

  @override
  Widget build(BuildContext context) {
    final hasDemoServer = context.select((ServersCubit cubit) => cubit.state.hasDemoServer);
    final isAdding = useState(false);

    if (hasDemoServer) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'No server of your own yet? The demo server runs inside the app and '
          'answers like a real one.',
          style: context.text.caption.copyWith(color: context.arkieColors.textFaint),
        ),
        const VSpace(space: ArkieMetrics.snug),
        OutlinedButton(
          onPressed: isAdding.value
              ? null
              : () async {
                  isAdding.value = true;
                  final server = await context.read<ServersCubit>().addDemoServer();
                  if (!context.mounted) return;
                  isAdding.value = false;
                  if (server != null) onAdded?.call();
                },
          child: Text(isAdding.value ? 'Adding…' : 'Add a demo server'),
        ),
      ],
    );
  }
}
