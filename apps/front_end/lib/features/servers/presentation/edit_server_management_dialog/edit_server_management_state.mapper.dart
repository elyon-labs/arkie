// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'edit_server_management_state.dart';

class EditServerManagementStateMapper
    extends ClassMapperBase<EditServerManagementState> {
  EditServerManagementStateMapper._();

  static EditServerManagementStateMapper? _instance;
  static EditServerManagementStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = EditServerManagementStateMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'EditServerManagementState';

  static bool _$enabled(EditServerManagementState v) => v.enabled;
  static const Field<EditServerManagementState, bool> _f$enabled = Field(
    'enabled',
    _$enabled,
  );
  static String _$sshHost(EditServerManagementState v) => v.sshHost;
  static const Field<EditServerManagementState, String> _f$sshHost = Field(
    'sshHost',
    _$sshHost,
  );
  static int _$sshPort(EditServerManagementState v) => v.sshPort;
  static const Field<EditServerManagementState, int> _f$sshPort = Field(
    'sshPort',
    _$sshPort,
  );
  static String _$sshUser(EditServerManagementState v) => v.sshUser;
  static const Field<EditServerManagementState, String> _f$sshUser = Field(
    'sshUser',
    _$sshUser,
  );
  static String _$hostKeyFingerprint(EditServerManagementState v) =>
      v.hostKeyFingerprint;
  static const Field<EditServerManagementState, String> _f$hostKeyFingerprint =
      Field('hostKeyFingerprint', _$hostKeyFingerprint);
  static String? _$privateKeyDisplayName(EditServerManagementState v) =>
      v.privateKeyDisplayName;
  static const Field<EditServerManagementState, String>
  _f$privateKeyDisplayName = Field(
    'privateKeyDisplayName',
    _$privateKeyDisplayName,
  );
  static PrivateKeyHealthStatus _$keyHealthStatus(
    EditServerManagementState v,
  ) => v.keyHealthStatus;
  static const Field<EditServerManagementState, PrivateKeyHealthStatus>
  _f$keyHealthStatus = Field('keyHealthStatus', _$keyHealthStatus);
  static bool _$isSelecting(EditServerManagementState v) => v.isSelecting;
  static const Field<EditServerManagementState, bool> _f$isSelecting = Field(
    'isSelecting',
    _$isSelecting,
  );
  static bool _$isSaving(EditServerManagementState v) => v.isSaving;
  static const Field<EditServerManagementState, bool> _f$isSaving = Field(
    'isSaving',
    _$isSaving,
  );
  static String? _$error(EditServerManagementState v) => v.error;
  static const Field<EditServerManagementState, String> _f$error = Field(
    'error',
    _$error,
    opt: true,
  );
  static String? _$cleanupWarning(EditServerManagementState v) =>
      v.cleanupWarning;
  static const Field<EditServerManagementState, String> _f$cleanupWarning =
      Field('cleanupWarning', _$cleanupWarning, opt: true);
  static bool _$saved(EditServerManagementState v) => v.saved;
  static const Field<EditServerManagementState, bool> _f$saved = Field(
    'saved',
    _$saved,
    opt: true,
    def: false,
  );
  static PrivateKeyReplacementReason? _$keyReplacementReason(
    EditServerManagementState v,
  ) => v.keyReplacementReason;
  static const Field<EditServerManagementState, PrivateKeyReplacementReason>
  _f$keyReplacementReason = Field(
    'keyReplacementReason',
    _$keyReplacementReason,
    opt: true,
  );

  @override
  final MappableFields<EditServerManagementState> fields = const {
    #enabled: _f$enabled,
    #sshHost: _f$sshHost,
    #sshPort: _f$sshPort,
    #sshUser: _f$sshUser,
    #hostKeyFingerprint: _f$hostKeyFingerprint,
    #privateKeyDisplayName: _f$privateKeyDisplayName,
    #keyHealthStatus: _f$keyHealthStatus,
    #isSelecting: _f$isSelecting,
    #isSaving: _f$isSaving,
    #error: _f$error,
    #cleanupWarning: _f$cleanupWarning,
    #saved: _f$saved,
    #keyReplacementReason: _f$keyReplacementReason,
  };

  static EditServerManagementState _instantiate(DecodingData data) {
    return EditServerManagementState(
      enabled: data.dec(_f$enabled),
      sshHost: data.dec(_f$sshHost),
      sshPort: data.dec(_f$sshPort),
      sshUser: data.dec(_f$sshUser),
      hostKeyFingerprint: data.dec(_f$hostKeyFingerprint),
      privateKeyDisplayName: data.dec(_f$privateKeyDisplayName),
      keyHealthStatus: data.dec(_f$keyHealthStatus),
      isSelecting: data.dec(_f$isSelecting),
      isSaving: data.dec(_f$isSaving),
      error: data.dec(_f$error),
      cleanupWarning: data.dec(_f$cleanupWarning),
      saved: data.dec(_f$saved),
      keyReplacementReason: data.dec(_f$keyReplacementReason),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EditServerManagementState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EditServerManagementState>(map);
  }

  static EditServerManagementState fromJson(String json) {
    return ensureInitialized().decodeJson<EditServerManagementState>(json);
  }
}

mixin EditServerManagementStateMappable {
  String toJson() {
    return EditServerManagementStateMapper.ensureInitialized()
        .encodeJson<EditServerManagementState>(
          this as EditServerManagementState,
        );
  }

  Map<String, dynamic> toMap() {
    return EditServerManagementStateMapper.ensureInitialized()
        .encodeMap<EditServerManagementState>(
          this as EditServerManagementState,
        );
  }

  EditServerManagementStateCopyWith<
    EditServerManagementState,
    EditServerManagementState,
    EditServerManagementState
  >
  get copyWith =>
      _EditServerManagementStateCopyWithImpl<
        EditServerManagementState,
        EditServerManagementState
      >(this as EditServerManagementState, $identity, $identity);
  @override
  String toString() {
    return EditServerManagementStateMapper.ensureInitialized().stringifyValue(
      this as EditServerManagementState,
    );
  }

  @override
  bool operator ==(Object other) {
    return EditServerManagementStateMapper.ensureInitialized().equalsValue(
      this as EditServerManagementState,
      other,
    );
  }

  @override
  int get hashCode {
    return EditServerManagementStateMapper.ensureInitialized().hashValue(
      this as EditServerManagementState,
    );
  }
}

extension EditServerManagementStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EditServerManagementState, $Out> {
  EditServerManagementStateCopyWith<$R, EditServerManagementState, $Out>
  get $asEditServerManagementState => $base.as(
    (v, t, t2) => _EditServerManagementStateCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class EditServerManagementStateCopyWith<
  $R,
  $In extends EditServerManagementState,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    bool? enabled,
    String? sshHost,
    int? sshPort,
    String? sshUser,
    String? hostKeyFingerprint,
    String? privateKeyDisplayName,
    PrivateKeyHealthStatus? keyHealthStatus,
    bool? isSelecting,
    bool? isSaving,
    String? error,
    String? cleanupWarning,
    bool? saved,
    PrivateKeyReplacementReason? keyReplacementReason,
  });
  EditServerManagementStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EditServerManagementStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EditServerManagementState, $Out>
    implements
        EditServerManagementStateCopyWith<$R, EditServerManagementState, $Out> {
  _EditServerManagementStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EditServerManagementState> $mapper =
      EditServerManagementStateMapper.ensureInitialized();
  @override
  $R call({
    bool? enabled,
    String? sshHost,
    int? sshPort,
    String? sshUser,
    String? hostKeyFingerprint,
    Object? privateKeyDisplayName = $none,
    PrivateKeyHealthStatus? keyHealthStatus,
    bool? isSelecting,
    bool? isSaving,
    Object? error = $none,
    Object? cleanupWarning = $none,
    bool? saved,
    Object? keyReplacementReason = $none,
  }) => $apply(
    FieldCopyWithData({
      if (enabled != null) #enabled: enabled,
      if (sshHost != null) #sshHost: sshHost,
      if (sshPort != null) #sshPort: sshPort,
      if (sshUser != null) #sshUser: sshUser,
      if (hostKeyFingerprint != null) #hostKeyFingerprint: hostKeyFingerprint,
      if (privateKeyDisplayName != $none)
        #privateKeyDisplayName: privateKeyDisplayName,
      if (keyHealthStatus != null) #keyHealthStatus: keyHealthStatus,
      if (isSelecting != null) #isSelecting: isSelecting,
      if (isSaving != null) #isSaving: isSaving,
      if (error != $none) #error: error,
      if (cleanupWarning != $none) #cleanupWarning: cleanupWarning,
      if (saved != null) #saved: saved,
      if (keyReplacementReason != $none)
        #keyReplacementReason: keyReplacementReason,
    }),
  );
  @override
  EditServerManagementState $make(CopyWithData data) =>
      EditServerManagementState(
        enabled: data.get(#enabled, or: $value.enabled),
        sshHost: data.get(#sshHost, or: $value.sshHost),
        sshPort: data.get(#sshPort, or: $value.sshPort),
        sshUser: data.get(#sshUser, or: $value.sshUser),
        hostKeyFingerprint: data.get(
          #hostKeyFingerprint,
          or: $value.hostKeyFingerprint,
        ),
        privateKeyDisplayName: data.get(
          #privateKeyDisplayName,
          or: $value.privateKeyDisplayName,
        ),
        keyHealthStatus: data.get(#keyHealthStatus, or: $value.keyHealthStatus),
        isSelecting: data.get(#isSelecting, or: $value.isSelecting),
        isSaving: data.get(#isSaving, or: $value.isSaving),
        error: data.get(#error, or: $value.error),
        cleanupWarning: data.get(#cleanupWarning, or: $value.cleanupWarning),
        saved: data.get(#saved, or: $value.saved),
        keyReplacementReason: data.get(
          #keyReplacementReason,
          or: $value.keyReplacementReason,
        ),
      );

  @override
  EditServerManagementStateCopyWith<$R2, EditServerManagementState, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _EditServerManagementStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

