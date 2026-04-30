import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';

class SetPrivacyModeEnabled {
  SetPrivacyModeEnabled({required this.settingsRepository});

  factory SetPrivacyModeEnabled.create() {
    return SetPrivacyModeEnabled(settingsRepository: inject());
  }

  final SettingsRepository settingsRepository;

  Future<void> call(bool isEnabled) {
    return settingsRepository.setPrivacyMode(isEnabled);
  }
}
