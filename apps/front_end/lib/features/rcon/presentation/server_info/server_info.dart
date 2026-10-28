import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/core_ui/flip_card.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/players_section/players_section.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/players_section/widgets/manage_players.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/saved_messages_section/saved_messages_section.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/saved_messages_section/widgets/edit_saved_messages.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_status_section/server_status_section.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_status_section/widgets/server_status_details.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/cancel_pending_map_change_snackbar.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/delete_server_button.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/maps_section.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/sidebar_wrapper.dart';
import 'package:dart_foundation/dart_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ServerInfo extends StatelessWidget {
  const ServerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final rconState = context.select((RCONCubit cubit) => cubit.state);

    return switch (rconState.connection) {
      Loaded<RCONConnection>(:final value) => _LoadedView(
        connection: value,
        server: rconState.server,
      ),
      Error<RCONConnection>(:final error) => _ErrorView(error: error),
      _ => const SizedBox.shrink(),
    };
  }
}

enum _ServerInfoView { front, editSavedMessages, managePlayers, serverStatusDetails }

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return SidebarWrapper(
      label: 'offline',
      child: Padding(
        padding: const EdgeInsets.all(ArkieMetrics.edge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Arkie cannot read this server.',
                  style: context.text.body.copyWith(color: context.colors.error),
                ),
                const VSpace(space: ArkieMetrics.tight),
                Text(
                  '$error',
                  style: context.text.caption.copyWith(color: context.arkieColors.textFaint),
                ),
              ],
            ),
            const DeleteServerButton(),
          ],
        ),
      ),
    );
  }
}

class _LoadedView extends HookWidget {
  const _LoadedView({required this.connection, required this.server});

  final RCONConnection connection;
  final Server server;

  @override
  Widget build(BuildContext context) {
    final flipController = useRef(FlipCardController());
    final view = useState(_ServerInfoView.front);

    useEffect(() {
      if (view.value != _ServerInfoView.front) {
        flipController.value.showBack();
      } else {
        flipController.value.showFront();
      }
      return null;
    }, [view.value]);

    void onCloseSidebar() {
      view.value = _ServerInfoView.front;
    }

    return BlocProvider(
      create: (context) => ServerInfoCubit.create(connection: connection),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlipCard(
            controller: flipController.value,
            front: _Sections(onServerInfoViewChange: (v) => view.value = v),
            back: switch (view.value) {
              _ServerInfoView.editSavedMessages => EditSavedMessages(onClose: onCloseSidebar),
              _ServerInfoView.managePlayers => ManagePlayers(onClose: onCloseSidebar),
              _ServerInfoView.serverStatusDetails => ServerStatusDetails(onClose: onCloseSidebar),
              // Show a blank sidebar for the default case
              _ => SidebarWrapper(child: Container()),
            },
          ),
          Builder(
            builder: (context) {
              final pendingAction = context.select(
                (ServerInfoCubit cubit) => cubit.state.pendingAction,
              );

              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(ArkieMetrics.snug),
                  child: CancelPendingActionSnackBar(pendingAction: pendingAction),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections({required this.onServerInfoViewChange});

  final ValueSetter<_ServerInfoView> onServerInfoViewChange;

  @override
  Widget build(BuildContext context) {
    return SidebarWrapper(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, overscroll: false),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ArkieMetrics.edge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ServerStatusSection(
                padding: const EdgeInsets.only(bottom: ArkieMetrics.loose),
                onMenuTap: () => onServerInfoViewChange(_ServerInfoView.serverStatusDetails),
              ),
              PlayersSection(
                padding: const EdgeInsets.only(bottom: ArkieMetrics.loose),
                onMenuTap: () => onServerInfoViewChange(_ServerInfoView.managePlayers),
              ),
              SavedMessagesSection(
                padding: const EdgeInsets.only(bottom: ArkieMetrics.loose),
                onMenuTap: () => onServerInfoViewChange(_ServerInfoView.editSavedMessages),
              ),
              const MapsSection(padding: EdgeInsets.zero),
            ],
          ),
        ),
      ),
    );
  }
}
