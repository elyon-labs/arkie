import 'package:arkie_core/features/rcon/domain/models/server_status.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/app/presentation/widgets/sensitive_text.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/delete_server_button.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/sidebar_wrapper.dart';
import 'package:dart_foundation/dart_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ServerStatusDetails extends HookWidget {
  const ServerStatusDetails({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final status = context.select((ServerInfoCubit cubit) => cubit.state.status);
    return switch (status) {
      Loaded(:final value) => _LoadedView(onClose: onClose, status: value),
      _ => const SizedBox.shrink(),
    };
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.onClose, required this.status});
  final VoidCallback onClose;
  final ServerStatus status;

  @override
  Widget build(BuildContext context) {
    return SidebarWrapper(
      label: 'details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ArkieMetrics.edge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Server details', style: context.text.title),
                      IconButton(onPressed: onClose, icon: Icon(context.icons.close)),
                    ],
                  ),
                  const VSpace(space: ArkieMetrics.snug),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: ArkieMetrics.gutter,
                    children: [
                      LabelValue(label: const Text('hostname'), value: Text(status.hostname)),
                      LabelValue(
                        label: const Text('address'),
                        value: SensitiveText.ipAddress(child: Text(status.address.address)),
                      ),
                      LabelValue(label: const Text('port'), value: Text('${status.port}')),
                      LabelValue(label: const Text('version'), value: Text(status.version)),
                      LabelValue(label: const Text('os'), value: Text(status.os)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(ArkieMetrics.edge), child: DeleteServerButton()),
        ],
      ),
    );
  }
}
