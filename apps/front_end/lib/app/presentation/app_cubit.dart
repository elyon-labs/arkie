import 'package:cs2_rcon_front_end/app/domain/set_privacy_mode_enabled.dart';
import 'package:cs2_rcon_front_end/app/domain/set_theme_mode.dart';
import 'package:cs2_rcon_front_end/app/domain/watch_is_privacy_mode_enabled.dart';
import 'package:cs2_rcon_front_end/app/domain/watch_theme_mode.dart';
import 'package:cs2_rcon_front_end/app/presentation/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit({
    required WatchIsPrivacyModeEnabled watchIsPrivacyModeEnabled,
    required SetPrivacyModeEnabled setPrivacyModeEnabled,
    required SetThemeMode setThemeMode,
    required WatchThemeMode watchThemeMode,
  }) : _watchIsPrivacyModeEnabled = watchIsPrivacyModeEnabled,
       _setPrivacyModeEnabled = setPrivacyModeEnabled,
       _setThemeMode = setThemeMode,
       _watchThemeMode = watchThemeMode,
       super(AppState.initial()) {
    _init();
  }

  factory AppCubit.create() {
    return AppCubit(
      watchIsPrivacyModeEnabled: WatchIsPrivacyModeEnabled.create(),
      setPrivacyModeEnabled: SetPrivacyModeEnabled.create(),
      setThemeMode: SetThemeMode.create(),
      watchThemeMode: WatchThemeMode.create(),
    );
  }

  final WatchIsPrivacyModeEnabled _watchIsPrivacyModeEnabled;
  final SetPrivacyModeEnabled _setPrivacyModeEnabled;
  final SetThemeMode _setThemeMode;
  final WatchThemeMode _watchThemeMode;

  final subs = CompositeSubscription();

  void _init() {
    final privacyModeSub = _watchIsPrivacyModeEnabled.call().listen((isEnabled) {
      emit(state.copyWith(isPrivacyModeEnabled: isEnabled));
    });
    final themeModeSub = _watchThemeMode.call().listen((mode) {
      emit(state.copyWith(themeMode: mode));
    });

    subs
      ..add(privacyModeSub)
      ..add(themeModeSub);
  }

  Future<void> setPrivacyModeEnabled(bool isEnabled) async {
    await _setPrivacyModeEnabled(isEnabled);
  }

  Future<void> togglePrivacyModeEnabled() async {
    await _setPrivacyModeEnabled(!state.isPrivacyModeEnabled);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _setThemeMode(mode);
  }

  @override
  Future<void> close() async {
    await subs.dispose();
    await super.close();
  }
}
