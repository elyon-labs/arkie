import 'package:cs2_rcon_front_end/app/domain/set_privacy_mode_enabled.dart';
import 'package:cs2_rcon_front_end/app/domain/watch_is_privacy_mode_enabled.dart';
import 'package:cs2_rcon_front_end/app/presentation/app_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit({
    required WatchIsPrivacyModeEnabled watchIsPrivacyModeEnabled,
    required SetPrivacyModeEnabled setPrivacyModeEnabled,
  }) : _watchIsPrivacyModeEnabled = watchIsPrivacyModeEnabled,
       _setPrivacyModeEnabled = setPrivacyModeEnabled,
       super(AppState.initial()) {
    _init();
  }

  factory AppCubit.create() {
    return AppCubit(
      watchIsPrivacyModeEnabled: WatchIsPrivacyModeEnabled.create(),
      setPrivacyModeEnabled: SetPrivacyModeEnabled.create(),
    );
  }

  final WatchIsPrivacyModeEnabled _watchIsPrivacyModeEnabled;
  final SetPrivacyModeEnabled _setPrivacyModeEnabled;

  final subs = CompositeSubscription();

  void _init() {
    final privacyModeSub = _watchIsPrivacyModeEnabled.call().listen((isEnabled) {
      emit(state.copyWith(isPrivacyModeEnabled: isEnabled));
    });

    subs.add(privacyModeSub);
  }

  Future<void> setPrivacyModeEnabled(bool isEnabled) async {
    await _setPrivacyModeEnabled(isEnabled);
  }

  Future<void> togglePrivacyModeEnabled() async {
    await _setPrivacyModeEnabled(!state.isPrivacyModeEnabled);
  }

  @override
  Future<void> close() async {
    await subs.dispose();
    await super.close();
  }
}
