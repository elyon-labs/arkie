import 'dart:async';

import 'package:cs2_rcon_front_end/core/safe_emit.dart';
import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/ssh_private_key_picker.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/private_key_health.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/server_management_draft.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/update_server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/edit_server_management_dialog/edit_server_management_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditServerManagementCubit extends Cubit<EditServerManagementState> {
  EditServerManagementCubit({
    required Server server,
    required UpdateServerManagementConfig update,
    required ManagedPrivateKeyStore privateKeyStore,
    required SshPrivateKeyPicker privateKeyPicker,
  }) : _server = server,
       _update = update,
       _privateKeyStore = privateKeyStore,
       _privateKeyPicker = privateKeyPicker,
       super(_initial(server)) {
    unawaited(_inspect());
  }

  factory EditServerManagementCubit.create(Server server) => EditServerManagementCubit(
    server: server,
    update: UpdateServerManagementConfig.create(),
    privateKeyStore: inject(),
    privateKeyPicker: inject(),
  );

  static EditServerManagementState _initial(Server server) {
    final config = server.managementConfig;
    return EditServerManagementState(
      enabled: config != null,
      sshHost: config?.sshHost ?? server.address,
      sshPort: config?.sshPort ?? 22,
      sshUser: config?.sshUser ?? 'arkie-cs2',
      hostKeyFingerprint: config?.hostKeyFingerprint ?? '',
      privateKeyDisplayName: config?.privateKey?.displayName,
      keyHealthStatus: PrivateKeyHealthStatus.checking,
      isSelecting: false,
      isSaving: false,
    );
  }

  final Server _server;
  final UpdateServerManagementConfig _update;
  final ManagedPrivateKeyStore _privateKeyStore;
  final SshPrivateKeyPicker _privateKeyPicker;
  SelectedPrivateKey? _selectedPrivateKey;

  Future<void> _inspect() async {
    final config = _server.managementConfig;
    final health = config == null
        ? const PrivateKeyReplacementRequired(PrivateKeyReplacementReason.missing)
        : config.privateKey == null
        ? const PrivateKeyReplacementRequired(PrivateKeyReplacementReason.legacyPath)
        : await _privateKeyStore.inspect(config.privateKey!);
    safeEmit(
      state.copyWith(
        keyHealthStatus: health is PrivateKeyUsable
            ? PrivateKeyHealthStatus.usable
            : PrivateKeyHealthStatus.replacementRequired,
        keyReplacementReason: health is PrivateKeyReplacementRequired ? health.reason : null,
      ),
    );
  }

  void setEnabled(bool value) => safeEmit(state.copyWith(enabled: value, error: null));
  void setSshHost(String value) => safeEmit(state.copyWith(sshHost: value));
  void setSshPort(int value) => safeEmit(state.copyWith(sshPort: value));
  void setSshUser(String value) => safeEmit(state.copyWith(sshUser: value));
  void setHostKeyFingerprint(String value) => safeEmit(state.copyWith(hostKeyFingerprint: value));

  Future<void> choosePrivateKey() async {
    safeEmit(state.copyWith(isSelecting: true, error: null));
    try {
      final selected = await _privateKeyPicker.pick();
      if (selected != null) {
        _selectedPrivateKey?.clear();
        _selectedPrivateKey = selected;
        safeEmit(
          state.copyWith(
            privateKeyDisplayName: selected.displayName,
            keyHealthStatus: PrivateKeyHealthStatus.usable,
            keyReplacementReason: null,
          ),
        );
      }
    } on Exception catch (error) {
      safeEmit(state.copyWith(error: error.toString()));
    } finally {
      safeEmit(state.copyWith(isSelecting: false));
    }
  }

  Future<void> save() async {
    if (state.enabled) {
      final validationError = _validate();
      if (validationError != null) {
        safeEmit(state.copyWith(error: validationError));
        return;
      }
    }
    safeEmit(state.copyWith(isSaving: true, error: null));
    final draft = state.enabled
        ? ServerManagementDraft(
            backend: ServerManagementBackend.systemd,
            sshHost: state.sshHost.trim(),
            sshPort: state.sshPort,
            sshUser: state.sshUser.trim(),
            hostKeyFingerprint: state.hostKeyFingerprint.trim(),
            selectedPrivateKey: _selectedPrivateKey,
          )
        : null;
    final result = await _update(server: _server, enabled: state.enabled, draft: draft);
    result.match((update) {
      _selectedPrivateKey?.clear();
      _selectedPrivateKey = null;
      safeEmit(state.copyWith(isSaving: false, saved: true, cleanupWarning: update.cleanupWarning));
    }, (error) => safeEmit(state.copyWith(isSaving: false, error: error.toString())));
  }

  String? _validate() {
    if (state.sshHost.trim().isEmpty) return 'SSH host cannot be empty.';
    if (state.sshPort <= 0 || state.sshPort > 65535) return 'SSH port must be 1–65535.';
    if (state.sshUser.trim().isEmpty) return 'SSH user cannot be empty.';
    if (state.hostKeyFingerprint.trim().isEmpty) return 'Host key fingerprint cannot be empty.';
    if (state.keyHealthStatus != PrivateKeyHealthStatus.usable) {
      return 'Choose a usable private key.';
    }
    return null;
  }

  @override
  Future<void> close() {
    _selectedPrivateKey?.clear();
    _selectedPrivateKey = null;
    return super.close();
  }
}
