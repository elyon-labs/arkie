import 'package:arkie_core/features/settings/data/repository/settings_repository.dart';
import 'package:rxdart/rxdart.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({String? selectedServerId, bool? privacyMode}) {
    if (selectedServerId != null) {
      _selectedServerSubject.add(selectedServerId);
    }
    if (privacyMode != null) {
      _privacyModeSubject.add(privacyMode);
    }
  }

  final _selectedServerSubject = BehaviorSubject<String?>.seeded(null);
  final _privacyModeSubject = BehaviorSubject<bool>.seeded(false);

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
  Future<void> dispose() async {
    if (!_selectedServerSubject.isClosed) {
      await _selectedServerSubject.close();
    }
    if (!_privacyModeSubject.isClosed) {
      await _privacyModeSubject.close();
    }
  }
}
