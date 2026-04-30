import 'package:cs2_rcon_front_end/app/presentation/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrivacyModeRow extends StatelessWidget {
  const PrivacyModeRow({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Privacy mode'),
      subtitle: const Text(
        'Mask sensitive information like IP addresses (does not mask the console itself)',
      ),
      onTap: () async => context.read<AppCubit>().togglePrivacyModeEnabled(),
      trailing: Switch(
        value: context.select((AppCubit cubit) => cubit.state.isPrivacyModeEnabled),
        onChanged: (isEnabled) async {
          await context.read<AppCubit>().setPrivacyModeEnabled(isEnabled);
        },
      ),
    );
  }
}
