import 'package:arkie_core/features/settings/domain/get_app_version_info.dart';
import 'package:arkie_core/features/settings/domain/models/update_status.dart';
import 'package:dart_foundation/dart_foundation.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:oxidized/oxidized.dart';

part 'app_version_state.mapper.dart';

@MappableClass()
class AppVersionState with AppVersionStateMappable {
  AppVersionState({required this.appVersion, required this.updateStatus});

  factory AppVersionState.initial({required Result<VersionInfo, Exception> appVersion}) {
    return AppVersionState(appVersion: appVersion, updateStatus: const Idle());
  }

  final Result<VersionInfo, Exception> appVersion;

  /// The update check is a network call, so it stays [Idle] until something
  /// asks for it and carries its own failure rather than hiding the version.
  final Async<UpdateStatus> updateStatus;
}
