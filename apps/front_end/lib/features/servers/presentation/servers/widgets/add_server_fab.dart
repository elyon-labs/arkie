import 'package:arkie_state/features/servers/servers_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddServerFAB extends StatelessWidget {
  const AddServerFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.edgePadding),
      child: FloatingActionButton.small(
        tooltip: 'Add Tab',
        onPressed: () => context.read<ServersCubit>().openTab(),
        child: Icon(context.icons.add),
      ),
    );
  }
}
