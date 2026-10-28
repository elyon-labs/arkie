import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/features/settings/data/repository/settings_repository.dart';
import 'package:flutter/material.dart';

class WatchThemeMode {
  WatchThemeMode({required this.settingsRepository});

  factory WatchThemeMode.create() {
    return WatchThemeMode(settingsRepository: inject());
  }

  final SettingsRepository settingsRepository;

  Stream<ThemeMode> call() {
    return settingsRepository.watchThemeMode();
  }
}
