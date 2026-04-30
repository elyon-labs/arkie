import 'package:cs2_rcon_front_end/app/presentation/widgets/sensitive_text.dart';
import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/core_ui/label_value.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/server_status.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/delete_server_button.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/sidebar_wrapper.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.sizes.edgeSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Server Details', style: context.text.header),
                      IconButton(onPressed: onClose, icon: Icon(context.icons.close)),
                    ],
                  ),
                  SizedBox(height: context.sizes.unit * 2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: context.sizes.unit * 1.5,
                    children: [
                      LabelValue(label: const Text('Hostname'), value: Text(status.hostname)),
                      LabelValue(
                        label: const Text('Address'),
                        value: SensitiveText.ipAddress(child: Text(status.address.address)),
                      ),
                      LabelValue(label: const Text('Port'), value: Text('${status.port}')),
                      LabelValue(label: const Text('Version'), value: Text(status.version)),
                      LabelValue(label: const Text('OS'), value: Text(status.os)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.sizes.edgeSpacing),
            child: const DeleteServerButton(),
          ),
        ],
      ),
    );
  }
}
