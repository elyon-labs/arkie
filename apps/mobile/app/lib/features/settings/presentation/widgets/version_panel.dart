import 'package:arkie_core/features/settings/domain/get_app_version_info.dart';
import 'package:arkie_core/features/settings/domain/models/update_status.dart';
import 'package:arkie_core/links.dart';
import 'package:arkie_state/features/settings/app_version_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:dart_foundation/dart_foundation.dart' as app_async;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';
import 'package:url_launcher/url_launcher.dart';

/// What build is running, with where it stands against the newest release
/// notched into the top border.
class VersionPanel extends StatelessWidget {
  const VersionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appVersion = context.select((AppVersionCubit cubit) => cubit.state.appVersion);

    return TerminalPanel(
      label: 'version',
      trailing: const _UpdateLamp(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          switch (appVersion) {
            Ok<VersionInfo, Exception>(:final value) => _InstalledVersion(value: value),
            Err<VersionInfo, Exception>() => Text(
              'This build does not say what version it is.',
              style: context.text.body.copyWith(color: context.colors.muted),
            ),
          },
          const VSpace(space: ArkieMetrics.snug),
          const Divider(),
          const VSpace(space: ArkieMetrics.snug),
          const _UpdateLine(),
        ],
      ),
    );
  }
}

class _InstalledVersion extends StatelessWidget {
  const _InstalledVersion({required this.value});

  final VersionInfo value;

  @override
  Widget build(BuildContext context) {
    // A build that was not given a build number reports its version as one,
    // and a line saying the version twice is worse than no line at all.
    final buildNumber = value.buildNumber;
    final hasBuildNumber = buildNumber.isNotEmpty && buildNumber != '${value.version}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelValue(label: const Text('version'), value: Text('${value.version}')),
        if (hasBuildNumber) ...[
          const VSpace(space: ArkieMetrics.gutter),
          LabelValue(label: const Text('build'), value: Text(buildNumber)),
        ],
      ],
    );
  }
}

/// A square lamp and a word for the update check, small enough to notch into
/// the panel's top border.
class _UpdateLamp extends StatelessWidget {
  const _UpdateLamp();

  @override
  Widget build(BuildContext context) {
    final status = context.select((AppVersionCubit cubit) => cubit.state.updateStatus);

    final (word, color) = switch (status) {
      app_async.Loaded<UpdateStatus>(value: UpToDate()) => ('latest', context.colors.good),
      app_async.Loaded<UpdateStatus>(value: UpdateAvailable()) => (
        'update',
        context.colors.warning,
      ),
      app_async.Error<UpdateStatus>() => ('unknown', context.colors.muted),
      _ => ('checking', context.colors.muted),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, color: color),
        const HSpace(space: ArkieMetrics.gutter + 2),
        Text(word, style: context.text.caption.copyWith(color: color)),
      ],
    );
  }
}

/// What the update check found, and whatever there is to do about it.
class _UpdateLine extends StatelessWidget {
  const _UpdateLine();

  @override
  Widget build(BuildContext context) {
    final status = context.select((AppVersionCubit cubit) => cubit.state.updateStatus);

    return switch (status) {
      app_async.Loaded<UpdateStatus>(value: UpToDate()) => const _Message('Arkie is up to date.'),
      app_async.Loaded<UpdateStatus>(value: UpdateAvailable(:final version)) => _Action(
        message: 'Arkie $version has been released.',
        label: 'See what changed',
        onPressed: () async => await launchUrl(Uri.parse(ArkieLinks.whatsNew)),
      ),
      app_async.Error<UpdateStatus>() => _Action(
        message: 'Could not reach the releases to check for an update.',
        label: 'Try again',
        onPressed: () async => await context.read<AppVersionCubit>().checkForUpdate(),
      ),
      _ => const _Message('Checking for a newer release…'),
    };
  }
}

class _Message extends StatelessWidget {
  const _Message(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: context.text.caption.copyWith(color: context.arkieColors.textFaint),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.message, required this.label, required this.onPressed});

  final String message;
  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Message(message),
        const VSpace(space: ArkieMetrics.tight),
        OutlinedButton(onPressed: () async => await onPressed(), child: Text(label)),
      ],
    );
  }
}
