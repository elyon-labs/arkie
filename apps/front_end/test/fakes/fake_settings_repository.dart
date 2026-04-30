import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:flutter/src/material/app.dart';
import 'package:rxdart/rxdart.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({String? selectedServerId, bool? privacyMode, ThemeMode? themeMode}) {
    if (selectedServerId != null) {
      _selectedServerSubject.add(selectedServerId);
    }
    if (privacyMode != null) {
      _privacyModeSubject.add(privacyMode);
    }
    if (themeMode != null) {
      _themeModeSubject.add(themeMode);
    }
  }

  final _selectedServerSubject = BehaviorSubject<String?>.seeded(null);
  final _privacyModeSubject = BehaviorSubject<bool>.seeded(false);
  final _themeModeSubject = BehaviorSubject<ThemeMode>.seeded(ThemeMode.system);

  @override
  Future<void> clearSelectedServer() {
    _selectedServerSubject.add(null);
    return Future.value();
  }

  @override
  Future<void> selectServer(String serverId) {
    _selectedServerSubject.add(serverId);
    return Future.value();
  }

  @override
  Future<void> setPrivacyMode(bool isEnabled) {
    _privacyModeSubject.add(isEnabled);
    return Future.value();
  }

  @override
  Stream<bool> watchIsPrivacyModeEnabled() {
    return _privacyModeSubject.stream;
  }

  @override
  Stream<String?> watchSelectedServer() {
    return _selectedServerSubject.stream;
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) {
    _themeModeSubject.add(mode);
    return Future.value();
  }

  @override
  Stream<ThemeMode> watchThemeMode() {
    return _themeModeSubject.stream;
  }

  @override
  Future<void> dispose() async {
    if (!_selectedServerSubject.isClosed) {
      await _selectedServerSubject.close();
    }
    if (!_privacyModeSubject.isClosed) {
      await _privacyModeSubject.close();
    }
  }
}
