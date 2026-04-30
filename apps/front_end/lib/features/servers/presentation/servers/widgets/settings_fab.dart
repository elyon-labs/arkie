import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/settings/presentation/settings.dart';
import 'package:flutter/material.dart';

class SettingsFab extends StatelessWidget {
  const SettingsFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.sizes.edgeSpacing),
      child: SizedBox(
        height: context.sizes.unit * 4.5,
        width: context.sizes.unit * 4.5,
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
