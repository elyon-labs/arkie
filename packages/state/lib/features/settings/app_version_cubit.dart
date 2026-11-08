import 'package:arkie_core/features/settings/domain/check_for_update.dart';
import 'package:arkie_core/features/settings/domain/get_app_version_info.dart';
import 'package:arkie_core/features/settings/domain/models/update_status.dart';
import 'package:arkie_state/core/safe_emit.dart';
import 'package:arkie_state/features/settings/app_version_state.dart';
import 'package:dart_foundation/dart_foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// What build is running, and whether a newer one has been published.
class AppVersionCubit extends Cubit<AppVersionState> {
  AppVersionCubit({
    required GetAppVersionInfo getAppVersionInfo,
    required CheckForUpdate checkForUpdate,
  }) : _checkForUpdate = checkForUpdate,
       super(AppVersionState.initial(appVersion: getAppVersionInfo()));

  factory AppVersionCubit.create() {
    return AppVersionCubit(
      getAppVersionInfo: GetAppVersionInfo.create(),
      checkForUpdate: CheckForUpdate.create(),
    );
  }

  final CheckForUpdate _checkForUpdate;

  Future<void> checkForUpdate() async {
    if (state.updateStatus.isLoading) return;

    safeEmit(state.copyWith(updateStatus: const Loading()));

    final result = await _checkForUpdate();
    safeEmit(
      state.copyWith(updateStatus: result.match<Async<UpdateStatus>>(Loaded.new, Error.new)),
    );
  }
}
