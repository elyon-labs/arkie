import 'package:arkie_core/features/settings/domain/get_app_version_info.dart';
import 'package:arkie_core/links.dart';
import 'package:arkie_state/features/settings/app_version_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';
import 'package:url_launcher/url_launcher.dart';

class AppVersionRow extends StatelessWidget {
  const AppVersionRow({super.key});

  @override
  Widget build(BuildContext context) {
    final appVersion = context.select((AppVersionCubit cubit) => cubit.state.appVersion);

    return switch (appVersion) {
      Ok<VersionInfo, Exception>(:final value) => Padding(
        padding: const EdgeInsets.all(ArkieMetrics.edge),
        child: Row(
          spacing: ArkieMetrics.tight,
          children: [
            const _GithubReleasesIcon(),
            _Version(value: value),
          ],
        ),
      ),
      Err<VersionInfo, Exception>() => const SizedBox.shrink(),
    };
  }
}

class _GithubReleasesIcon extends StatelessWidget {
  const _GithubReleasesIcon();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          await launchUrl(Uri.parse(ArkieLinks.releases));
        },
        child: Tooltip(
          message: 'See Releases on GitHub',
          child: Icon(context.icons.github, color: context.colors.muted),
        ),
      ),
    );
  }
}

class _Version extends StatelessWidget {
  const _Version({required this.value});

  final VersionInfo value;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: 'v${value.version} (${value.buildNumber})'));
          if (!context.mounted) return;

          final snackBar = SnackBar(
            content: Text('Copied version v${value.version} (${value.buildNumber}) to clipboard'),
            duration: const Duration(milliseconds: 500),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: Tooltip(
          message: 'Tap to copy',
          child: Text('v${value.version} (${value.buildNumber})', style: context.text.caption),
        ),
      ),
    );
  }
}
