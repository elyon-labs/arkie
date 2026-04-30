import 'package:cs2_rcon_front_end/features/settings/domain/get_app_version_info.dart';
import 'package:cs2_rcon_front_end/features/settings/presentation/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required GetAppVersionInfo getAppVersionInfo})
    : super(SettingsState.initial(appVersion: getAppVersionInfo()));

  factory SettingsCubit.create() {
    return SettingsCubit(getAppVersionInfo: GetAppVersionInfo.create());
  }
}
