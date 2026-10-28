import 'package:arkie_state/features/servers/servers_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens another tab, sitting at the end of the strip where the next one lands.
class AddServerFAB extends StatelessWidget {
  const AddServerFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ArkieMetrics.gutter),
      child: IconButton(
        tooltip: 'Open a tab',
        onPressed: () => context.read<ServersCubit>().openTab(),
        icon: Icon(context.icons.add),
      ),
    );
  }
}
