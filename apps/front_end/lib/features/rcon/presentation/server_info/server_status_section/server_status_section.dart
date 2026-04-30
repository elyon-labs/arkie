import 'package:cs2_rcon_front_end/app/presentation/widgets/sensitive_text.dart';
import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/core_ui/label_value.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/server_status.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/section_header.dart';
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
        spacing: context.sizes.unit,
        children: [
          SectionHeader(
            title: Text(status.hostname, overflow: TextOverflow.ellipsis, maxLines: 1),
            actions: [IconButton(onPressed: onMenuTap, icon: Icon(context.icons.menu))],
          ),
          SizedBox(height: context.sizes.unit),
          LabelValue(
            label: const Text('Address'),
            value: SensitiveText.ipAddress(child: Text(status.address.address)),
          ),
          LabelValue(
            label: const Text('Players'),
            value: Text(
              '${status.numPlayers} (Humans: ${status.numHumans}, Bots: ${status.numBots})',
            ),
          ),
          LabelValue(label: const Text('Map'), value: Text(status.map)),
        ],
      ),
    );
  }
}
