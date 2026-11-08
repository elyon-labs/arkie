import 'dart:async';

import 'package:arkie_mobile/features/settings/presentation/widgets/links_panel.dart';
import 'package:arkie_mobile/features/settings/presentation/widgets/version_panel.dart';
import 'package:arkie_state/features/settings/app_version_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => AppVersionCubit.create(), child: const _SettingsView());
  }
}

class _SettingsView extends HookWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppVersionCubit>();

    useEffect(() {
      unawaited(cubit.checkForUpdate());
      return null;
    }, [cubit]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(context.icons.back),
          tooltip: 'Back to servers',
        ),
        titleSpacing: 0,
        title: const Text('settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ArkieMetrics.edge,
          ArkieMetrics.loose,
          ArkieMetrics.edge,
          ArkieMetrics.section,
        ),
        children: const [
          VersionPanel(),
          VSpace(space: ArkieMetrics.loose),
          LinksPanel(),
        ],
      ),
    );
  }
}
