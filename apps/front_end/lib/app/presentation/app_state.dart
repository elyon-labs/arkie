import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'app_state.mapper.dart';

@MappableClass()
class AppState with AppStateMappable {
  AppState({required this.isPrivacyModeEnabled, required this.themeMode});

  factory AppState.initial() {
    return AppState(isPrivacyModeEnabled: false, themeMode: ThemeMode.system);
  }

  final bool isPrivacyModeEnabled;
  final ThemeMode themeMode;
}
