import 'dart:async';

import 'package:arkie_state/features/settings/app_version_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/features/settings/presentation/widgets/app_version_row.dart';
import 'package:cs2_rcon_front_end/features/settings/presentation/widgets/file_issue_row.dart';
import 'package:cs2_rcon_front_end/features/settings/presentation/widgets/privacy_mode_row.dart';
import 'package:cs2_rcon_front_end/features/settings/presentation/widgets/update_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppVersionCubit.create(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends HookWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppVersionCubit>();

    useEffect(() {
      unawaited(cubit.checkForUpdate());
      return null;
    }, [cubit]);

    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: ArkieMetrics.snug),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: ArkieMetrics.tight,
              children: [PrivacyModeRow(), UpdateRow(), FileIssueRow()],
            ),
          ),
        ),
        AppVersionRow(),
      ],
    );
  }
}
