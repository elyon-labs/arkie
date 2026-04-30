import 'package:cs2_rcon_front_end/features/settings/domain/get_app_version_info.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:oxidized/oxidized.dart';

part 'settings_state.mapper.dart';

@MappableClass()
class SettingsState with SettingsStateMappable {
  SettingsState({required this.appVersion});

  factory SettingsState.initial({required Result<VersionInfo, Exception> appVersion}) {
    return SettingsState(appVersion: appVersion);
  }

  final Result<VersionInfo, Exception> appVersion;
}
