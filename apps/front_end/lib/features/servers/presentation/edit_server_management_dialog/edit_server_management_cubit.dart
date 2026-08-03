import 'package:cs2_rcon_front_end/core/safe_emit.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/select_ssh_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/models/server_management_draft.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/update_server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/edit_server_management_dialog/edit_server_management_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditServerManagementCubit extends Cubit<EditServerManagementState> {
  EditServerManagementCubit({
    required Server server,
    required UpdateServerManagementConfig updateServerManagementConfig,
    required SelectSshPrivateKey selectSshPrivateKey,
  }) : _server = server,
       _updateServerManagementConfig = updateServerManagementConfig,
       _selectSshPrivateKey = selectSshPrivateKey,
       _existingPrivateKeyDisplayName = server.managementConfig?.privateKey?.displayName,
       super(_initialState(server));

  factory EditServerManagementCubit.create(Server server) {
    return EditServerManagementCubit(
      server: server,
      updateServerManagementConfig: UpdateServerManagementConfig.create(),
      selectSshPrivateKey: SelectSshPrivateKey.create(),
    );
  }

  static EditServerManagementState _initialState(Server server) {
    final config = server.managementConfig;
    return EditServerManagementState(
      enabled: config != null,
      sshHost: config?.sshHost ?? server.address,
      sshPort: config?.sshPort ?? 22,
      sshUser: config?.sshUser ?? 'arkie-cs2',
      hostKeyFingerprint: config?.hostKeyFingerprint ?? '',
      privateKeyDisplayName: config?.privateKey?.displayName,
      isSelectingPrivateKey: false,
      isSaving: false,
    );
  }

  final Server _server;
  final UpdateServerManagementConfig _updateServerManagementConfig;
  final SelectSshPrivateKey _selectSshPrivateKey;
  final String? _existingPrivateKeyDisplayName;

  SelectedPrivateKey? _selectedPrivateKey;

  bool get _isBusy => state.isSelectingPrivateKey || state.isSaving;

  void setEnabled(bool enabled) {
    if (_isBusy) {
      return;
    }
    if (!enabled) {
      _clearSelectedPrivateKey();
    }
    safeEmit(
      state.copyWith(
        enabled: enabled,
        privateKeyDisplayName: enabled
            ? state.privateKeyDisplayName
            : _existingPrivateKeyDisplayName,
        error: null,
      ),
    );
  }

  void setSshHost(String sshHost) => safeEmit(state.copyWith(sshHost: sshHost));

  void setSshPort(int sshPort) => safeEmit(state.copyWith(sshPort: sshPort));

  void setSshUser(String sshUser) => safeEmit(state.copyWith(sshUser: sshUser));

  void setHostKeyFingerprint(String fingerprint) {
    safeEmit(state.copyWith(hostKeyFingerprint: fingerprint));
  }

  Future<void> selectPrivateKey() async {
    if (_isBusy || !state.enabled) {
      return;
    }
    safeEmit(state.copyWith(isSelectingPrivateKey: true, error: null));
    final result = await _selectSshPrivateKey();
    result.match((selected) {
      if (selected != null) {
        _clearSelectedPrivateKey();
        _selectedPrivateKey = selected;
      }
      safeEmit(
        state.copyWith(
          isSelectingPrivateKey: false,
          privateKeyDisplayName: selected?.displayName ?? state.privateKeyDisplayName,
          error: null,
        ),
      );
    }, (error) => safeEmit(state.copyWith(isSelectingPrivateKey: false, error: error.toString())));
  }

  Future<void> save() async {
    if (_isBusy) {
      return;
    }
    final validationError = _validationError();
    if (validationError != null) {
      safeEmit(state.copyWith(error: validationError));
      return;
    }

    safeEmit(state.copyWith(isSaving: true, error: null));
    final update = state.enabled
        ? SaveServerManagementConfig(
            ServerManagementDraft(
              backend: ServerManagementBackend.systemd,
              sshHost: state.sshHost.trim(),
              sshPort: state.sshPort,
              sshUser: state.sshUser.trim(),
              selectedPrivateKey: _selectedPrivateKey,
              hostKeyFingerprint: state.hostKeyFingerprint.trim(),
            ),
          )
        : const DisableServerManagementConfig();
    final result = await _updateServerManagementConfig(server: _server, update: update);
    result.match((update) {
      _clearSelectedPrivateKey();
      safeEmit(state.copyWith(isSaving: false, saved: true, cleanupWarning: update.cleanupWarning));
    }, (error) => safeEmit(state.copyWith(isSaving: false, error: error.toString())));
  }

  String? _validationError() {
    if (!state.enabled) {
      return null;
    }
    if (state.sshHost.trim().isEmpty) {
      return 'SSH host cannot be empty.';
    }
    if (state.sshPort <= 0 || state.sshPort > 65535) {
      return 'SSH port must be between 1 and 65535.';
    }
    if (state.sshUser.trim().isEmpty) {
      return 'SSH user cannot be empty.';
    }
    if (state.privateKeyDisplayName == null) {
      return 'Select an SSH private key.';
    }
    if (state.hostKeyFingerprint.trim().isEmpty) {
      return 'Host key fingerprint cannot be empty.';
    }
    return null;
  }

  void _clearSelectedPrivateKey() {
    _selectedPrivateKey?.clear();
    _selectedPrivateKey = null;
  }

  @override
  Future<void> close() {
    _clearSelectedPrivateKey();
    return super.close();
  }
}
