import 'package:cs2_rcon_front_end/app/presentation/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SensitiveTextType { ipAddress }

class SensitiveText extends StatelessWidget {
  factory SensitiveText.ipAddress({Key? key, required Widget child}) {
    return SensitiveText._(key: key, type: SensitiveTextType.ipAddress, child: child);
  }

  const SensitiveText._({super.key, required this.type, required this.child});

  final SensitiveTextType type;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isPrivacyModeEnabled = context.select(
      (AppCubit cubit) => cubit.state.isPrivacyModeEnabled,
    );

    if (!isPrivacyModeEnabled) return child;

    return switch (type) {
      SensitiveTextType.ipAddress => const _MaskedIpAddress(),
    };
  }
}

class _MaskedIpAddress extends StatelessWidget {
  const _MaskedIpAddress();

  @override
  Widget build(BuildContext context) {
    return const Text('●●●.●●●.●●●.●●●');
  }
}
