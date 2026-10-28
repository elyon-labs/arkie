import 'package:arkie_core/features/rcon/domain/models/server_status.dart';
import 'package:arkie_state/features/rcon/server_info/server_info_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/app/presentation/widgets/sensitive_text.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/section_header.dart';
import 'package:dart_foundation/dart_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServerStatusSection extends StatelessWidget {
  const ServerStatusSection({super.key, required this.onMenuTap, required this.padding});

  final VoidCallback onMenuTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final status = context.select((ServerInfoCubit cubit) => cubit.state.status);

    return switch (status) {
      Loaded(:final value) => _LoadedStatus(status: value, onMenuTap: onMenuTap, padding: padding),
      _ => const SizedBox.shrink(),
    };
  }
}

class _LoadedStatus extends StatelessWidget {
  const _LoadedStatus({required this.status, required this.onMenuTap, required this.padding});

  final ServerStatus status;
  final VoidCallback onMenuTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            status.hostname,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: context.text.title,
          ),
          const VSpace(space: ArkieMetrics.snug),
          SectionHeader(
            title: const Text('status'),
            actions: [IconButton(onPressed: onMenuTap, icon: Icon(context.icons.menu))],
          ),
          const VSpace(space: ArkieMetrics.tight),
          LabelValue(
            label: const Text('address'),
            value: SensitiveText.ipAddress(child: Text(status.address.address)),
          ),
          LabelValue(label: const Text('players'), value: Text('${status.numPlayers}')),
          LabelValue(label: const Text('humans'), value: Text('${status.numHumans}')),
          LabelValue(label: const Text('bots'), value: Text('${status.numBots}')),
          LabelValue(label: const Text('map'), value: Text(status.map)),
        ],
      ),
    );
  }
}
