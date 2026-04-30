import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
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
