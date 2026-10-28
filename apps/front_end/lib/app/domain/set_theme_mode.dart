import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/features/settings/data/repository/settings_repository.dart';
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
