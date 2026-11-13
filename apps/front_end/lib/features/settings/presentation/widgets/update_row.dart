import 'package:arkie_core/features/settings/domain/models/update_status.dart';
import 'package:arkie_core/links.dart';
import 'package:arkie_state/features/settings/app_version_cubit.dart';
import 'package:dart_foundation/dart_foundation.dart' as app_async;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// Where this build stands against the newest published release.
///
/// An available update sends you to the releases rather than installing
/// anything: the installers are attached there, and which one you want depends
/// on the machine you are reading this on.
class UpdateRow extends StatelessWidget {
  const UpdateRow({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select((AppVersionCubit cubit) => cubit.state.updateStatus);

    return switch (status) {
      app_async.Loaded<UpdateStatus>(value: UpToDate()) => const ListTile(
        title: Text('Updates'),
        subtitle: Text('Arkie is up to date'),
      ),
      app_async.Loaded<UpdateStatus>(value: UpdateAvailable(:final version)) => ListTile(
        title: const Text('Updates'),
        subtitle: Text('Arkie $version has been released'),
        trailing: const Icon(Icons.open_in_new),
        onTap: () async => await launchUrl(Uri.parse(ArkieLinks.releases)),
      ),
      app_async.Error<UpdateStatus>() => ListTile(
        title: const Text('Updates'),
        subtitle: const Text('Could not reach the releases to check for an update'),
        trailing: const Icon(Icons.refresh),
        onTap: () async => await context.read<AppVersionCubit>().checkForUpdate(),
      ),
      _ => const ListTile(title: Text('Updates'), subtitle: Text('Checking for a newer release…')),
    };
  }
}
