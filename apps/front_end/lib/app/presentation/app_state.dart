import 'package:dart_mappable/dart_mappable.dart';

part 'app_state.mapper.dart';

@MappableClass()
class AppState with AppStateMappable {
  AppState({required this.isPrivacyModeEnabled});

  factory AppState.initial() {
    return AppState(isPrivacyModeEnabled: false);
  }

  final bool isPrivacyModeEnabled;
}
