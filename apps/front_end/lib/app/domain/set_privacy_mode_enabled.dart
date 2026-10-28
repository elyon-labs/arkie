import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/features/settings/data/repository/settings_repository.dart';

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
