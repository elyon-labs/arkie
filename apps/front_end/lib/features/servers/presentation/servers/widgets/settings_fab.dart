import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/features/settings/presentation/settings.dart';
import 'package:flutter/material.dart';

class SettingsFab extends StatelessWidget {
  const SettingsFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.edgePadding),
      child: SizedBox(
        height: Sizes.unit * 4.5,
        width: Sizes.unit * 4.5,
        child: FloatingActionButton.small(
          tooltip: 'Settings',
          onPressed: () async {
            await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const Settings()));
          },
          child: Icon(context.icons.settings),
        ),
      ),
    );
  }
}
