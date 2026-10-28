import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/features/settings/data/repository/settings_repository.dart';

class WatchIsPrivacyModeEnabled {
  WatchIsPrivacyModeEnabled({required this.settingsRepository});

  factory WatchIsPrivacyModeEnabled.create() {
    return WatchIsPrivacyModeEnabled(settingsRepository: inject());
  }

  final SettingsRepository settingsRepository;

  Stream<bool> call() {
    return settingsRepository.watchIsPrivacyModeEnabled();
  }
}
