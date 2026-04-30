import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/settings/domain/get_app_version_info.dart';
import 'package:cs2_rcon_front_end/features/settings/presentation/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';
import 'package:url_launcher/url_launcher.dart';

class AppVersionRow extends StatelessWidget {
  const AppVersionRow({super.key});

  @override
  Widget build(BuildContext context) {
    final appVersion = context.select((SettingsCubit cubit) => cubit.state.appVersion);

    return switch (appVersion) {
      Ok<VersionInfo, Exception>(:final value) => Padding(
        padding: EdgeInsets.all(context.sizes.edgeSpacing),
        child: Row(
          spacing: context.sizes.unit,
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
          await launchUrl(Uri.parse('https://github.com/elyon-labs/arkie/releases'));
        },
        child: Tooltip(
          message: 'See Releases on GitHub',
          child: Icon(context.icons.github, color: context.colors.foregroundMuted),
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
