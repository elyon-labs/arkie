import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';

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
