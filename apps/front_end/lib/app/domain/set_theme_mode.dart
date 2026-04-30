import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:flutter/material.dart';

class SetThemeMode {
  SetThemeMode({required this.settingsRepository});

  factory SetThemeMode.create() {
    return SetThemeMode(settingsRepository: inject());
  }

  final SettingsRepository settingsRepository;

  Future<void> call(ThemeMode mode) {
    return settingsRepository.setThemeMode(mode);
  }
}
