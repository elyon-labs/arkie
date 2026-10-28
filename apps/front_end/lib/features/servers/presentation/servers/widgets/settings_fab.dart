import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/features/settings/presentation/settings.dart';
import 'package:flutter/material.dart';

class SettingsFab extends StatelessWidget {
  const SettingsFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ArkieMetrics.tight),
      child: IconButton(
        tooltip: 'Settings',
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (context) => const Settings()));
        },
        icon: Icon(context.icons.settings),
      ),
    );
  }
}
