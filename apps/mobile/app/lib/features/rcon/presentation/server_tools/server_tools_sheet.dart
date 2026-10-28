import 'package:arkie_mobile/features/rcon/presentation/server_tools/maps_tab.dart';
import 'package:arkie_mobile/features/rcon/presentation/server_tools/players_tab.dart';
import 'package:arkie_mobile/features/rcon/presentation/server_tools/saved_commands_tab.dart';
import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens the saved commands / maps / players sheet.
///
/// The sheet's route is inserted as a sibling of the page in the Overlay, so
/// it does not inherit BlocProviders set up inside the page's own build
/// method. The cubits are read from [context] here, before the sheet opens,
/// and re-provided via `BlocProvider.value` so the sheet's tabs can safely
/// depend on them.
Future<void> showServerToolsSheet(BuildContext context) async {
  final rconCubit = context.read<RCONCubit>();
  final serverInfoCubit = context.read<ServerInfoCubit?>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: rconCubit),
        if (serverInfoCubit != null) BlocProvider.value(value: serverInfoCubit),
      ],
      child: const ServerToolsSheet(),
    ),
  );
}

/// The tabs are named for what they hold, in the lower case the rest of the
/// console uses, so the sheet reads as another pane rather than a new screen.
class ServerToolsSheet extends StatelessWidget {
  const ServerToolsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const FractionallySizedBox(
      heightFactor: 0.84,
      child: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'saved'),
                  Tab(text: 'maps'),
                  Tab(text: 'players'),
                ],
              ),
              Expanded(child: TabBarView(children: [SavedCommandsTab(), MapsTab(), PlayersTab()])),
            ],
          ),
        ),
      ),
    );
  }
}
