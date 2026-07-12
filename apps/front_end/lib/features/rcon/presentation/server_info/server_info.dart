import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/core_ui/flip_card.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/players_section/players_section.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/players_section/widgets/manage_players.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/saved_messages_section/saved_messages_section.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/saved_messages_section/widgets/edit_saved_messages.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_status_section/server_status_section.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_status_section/widgets/server_status_details.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/cancel_pending_map_change_snackbar.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/delete_server_button.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/maps_section.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/sidebar_wrapper.dart';
import 'package:cs2_rcon_front_end/features/server_management/presentation/server_management_section.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ServerInfo extends StatelessWidget {
  const ServerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final rconState = context.select((RCONCubit cubit) => cubit.state);

    return switch (rconState.connection) {
      Loaded<RCONConnection>(:final value) => _LoadedView(connection: value, server: rconState.server),
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
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(context.sizes.edgeSpacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Error loading server info: $error'), const DeleteServerButton()],
          ),
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
            front: _Sections(server: server, onServerInfoViewChange: (v) => view.value = v),
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
                  padding: EdgeInsets.all(context.sizes.edgeSpacing),
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
  const _Sections({required this.server, required this.onServerInfoViewChange});

  final Server server;

  final ValueSetter<_ServerInfoView> onServerInfoViewChange;

  @override
  Widget build(BuildContext context) {
    return SidebarWrapper(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, overscroll: false),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.sizes.edgeSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ServerStatusSection(
                padding: EdgeInsets.symmetric(vertical: context.sizes.unit),
                onMenuTap: () => onServerInfoViewChange(_ServerInfoView.serverStatusDetails),
              ),
              PlayersSection(
                padding: EdgeInsets.symmetric(vertical: context.sizes.unit),
                onMenuTap: () => onServerInfoViewChange(_ServerInfoView.managePlayers),
              ),
              SavedMessagesSection(
                padding: EdgeInsets.symmetric(vertical: context.sizes.unit),
                onMenuTap: () => onServerInfoViewChange(_ServerInfoView.editSavedMessages),
              ),
              MapsSection(padding: EdgeInsets.symmetric(vertical: context.sizes.unit * 1.5)),
              ServerManagementSection(server: server),
            ],
          ),
        ),
      ),
    );
  }
}
