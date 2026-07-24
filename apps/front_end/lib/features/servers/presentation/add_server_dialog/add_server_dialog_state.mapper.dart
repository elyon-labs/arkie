// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'add_server_dialog_state.dart';

class AddServerDialogStateMapper extends ClassMapperBase<AddServerDialogState> {
  AddServerDialogStateMapper._();

  static AddServerDialogStateMapper? _instance;
  static AddServerDialogStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AddServerDialogStateMapper._());
      ServerMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AddServerDialogState';

  static Async<Result<Server, String>> _$addServerResult(
    AddServerDialogState v,
  ) => v.addServerResult;
  static const Field<AddServerDialogState, Async<Result<Server, String>>>
  _f$addServerResult = Field('addServerResult', _$addServerResult);
  static String _$name(AddServerDialogState v) => v.name;
  static const Field<AddServerDialogState, String> _f$name = Field(
    'name',
    _$name,
  );
  static String _$address(AddServerDialogState v) => v.address;
  static const Field<AddServerDialogState, String> _f$address = Field(
    'address',
    _$address,
  );
  static int _$port(AddServerDialogState v) => v.port;
  static const Field<AddServerDialogState, int> _f$port = Field('port', _$port);
  static String _$password(AddServerDialogState v) => v.password;
  static const Field<AddServerDialogState, String> _f$password = Field(
    'password',
    _$password,
  );
  static bool _$enableManagement(AddServerDialogState v) => v.enableManagement;
  static const Field<AddServerDialogState, bool> _f$enableManagement = Field(
    'enableManagement',
    _$enableManagement,
    opt: true,
    def: false,
  );
  static String _$sshHost(AddServerDialogState v) => v.sshHost;
  static const Field<AddServerDialogState, String> _f$sshHost = Field(
    'sshHost',
    _$sshHost,
    opt: true,
    def: '',
  );
  static int _$sshPort(AddServerDialogState v) => v.sshPort;
  static const Field<AddServerDialogState, int> _f$sshPort = Field(
    'sshPort',
    _$sshPort,
    opt: true,
    def: 22,
  );
  static String _$sshUser(AddServerDialogState v) => v.sshUser;
  static const Field<AddServerDialogState, String> _f$sshUser = Field(
    'sshUser',
    _$sshUser,
    opt: true,
    def: 'arkie-cs2',
  );
  static bool _$isSelectingPrivateKey(AddServerDialogState v) =>
      v.isSelectingPrivateKey;
  static const Field<AddServerDialogState, bool> _f$isSelectingPrivateKey =
      Field(
        'isSelectingPrivateKey',
        _$isSelectingPrivateKey,
        opt: true,
        def: false,
      );
  static String? _$privateKeyDisplayName(AddServerDialogState v) =>
      v.privateKeyDisplayName;
  static const Field<AddServerDialogState, String> _f$privateKeyDisplayName =
      Field('privateKeyDisplayName', _$privateKeyDisplayName, opt: true);
  static String? _$privateKeySelectionError(AddServerDialogState v) =>
      v.privateKeySelectionError;
  static const Field<AddServerDialogState, String> _f$privateKeySelectionError =
      Field('privateKeySelectionError', _$privateKeySelectionError, opt: true);
  static String _$hostKeyFingerprint(AddServerDialogState v) =>
      v.hostKeyFingerprint;
  static const Field<AddServerDialogState, String> _f$hostKeyFingerprint =
      Field('hostKeyFingerprint', _$hostKeyFingerprint, opt: true, def: '');

  @override
  final MappableFields<AddServerDialogState> fields = const {
    #addServerResult: _f$addServerResult,
    #name: _f$name,
    #address: _f$address,
    #port: _f$port,
    #password: _f$password,
    #enableManagement: _f$enableManagement,
    #sshHost: _f$sshHost,
    #sshPort: _f$sshPort,
    #sshUser: _f$sshUser,
    #isSelectingPrivateKey: _f$isSelectingPrivateKey,
    #privateKeyDisplayName: _f$privateKeyDisplayName,
    #privateKeySelectionError: _f$privateKeySelectionError,
    #hostKeyFingerprint: _f$hostKeyFingerprint,
  };

  static AddServerDialogState _instantiate(DecodingData data) {
    return AddServerDialogState(
      addServerResult: data.dec(_f$addServerResult),
      name: data.dec(_f$name),
      address: data.dec(_f$address),
      port: data.dec(_f$port),
      password: data.dec(_f$password),
      enableManagement: data.dec(_f$enableManagement),
      sshHost: data.dec(_f$sshHost),
      sshPort: data.dec(_f$sshPort),
      sshUser: data.dec(_f$sshUser),
      isSelectingPrivateKey: data.dec(_f$isSelectingPrivateKey),
      privateKeyDisplayName: data.dec(_f$privateKeyDisplayName),
      privateKeySelectionError: data.dec(_f$privateKeySelectionError),
      hostKeyFingerprint: data.dec(_f$hostKeyFingerprint),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AddServerDialogState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AddServerDialogState>(map);
  }

  static AddServerDialogState fromJson(String json) {
    return ensureInitialized().decodeJson<AddServerDialogState>(json);
  }
}

mixin AddServerDialogStateMappable {
  String toJson() {
    return AddServerDialogStateMapper.ensureInitialized()
        .encodeJson<AddServerDialogState>(this as AddServerDialogState);
  }

  Map<String, dynamic> toMap() {
    return AddServerDialogStateMapper.ensureInitialized()
        .encodeMap<AddServerDialogState>(this as AddServerDialogState);
  }

  AddServerDialogStateCopyWith<
    AddServerDialogState,
    AddServerDialogState,
    AddServerDialogState
  >
  get copyWith =>
      _AddServerDialogStateCopyWithImpl<
        AddServerDialogState,
        AddServerDialogState
      >(this as AddServerDialogState, $identity, $identity);
  @override
  String toString() {
    return AddServerDialogStateMapper.ensureInitialized().stringifyValue(
      this as AddServerDialogState,
    );
  }

  @override
  bool operator ==(Object other) {
    return AddServerDialogStateMapper.ensureInitialized().equalsValue(
      this as AddServerDialogState,
      other,
    );
  }

  @override
  int get hashCode {
    return AddServerDialogStateMapper.ensureInitialized().hashValue(
      this as AddServerDialogState,
    );
  }
}

extension AddServerDialogStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AddServerDialogState, $Out> {
  AddServerDialogStateCopyWith<$R, AddServerDialogState, $Out>
  get $asAddServerDialogState => $base.as(
    (v, t, t2) => _AddServerDialogStateCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class AddServerDialogStateCopyWith<
  $R,
  $In extends AddServerDialogState,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    Async<Result<Server, String>>? addServerResult,
    String? name,
    String? address,
    int? port,
    String? password,
    bool? enableManagement,
    String? sshHost,
    int? sshPort,
    String? sshUser,
    bool? isSelectingPrivateKey,
    String? privateKeyDisplayName,
    String? privateKeySelectionError,
    String? hostKeyFingerprint,
  });
  AddServerDialogStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AddServerDialogStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AddServerDialogState, $Out>
    implements AddServerDialogStateCopyWith<$R, AddServerDialogState, $Out> {
  _AddServerDialogStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AddServerDialogState> $mapper =
      AddServerDialogStateMapper.ensureInitialized();
  @override
  $R call({
    Async<Result<Server, String>>? addServerResult,
    String? name,
    String? address,
    int? port,
    String? password,
    bool? enableManagement,
    String? sshHost,
    int? sshPort,
    String? sshUser,
    bool? isSelectingPrivateKey,
    Object? privateKeyDisplayName = $none,
    Object? privateKeySelectionError = $none,
    String? hostKeyFingerprint,
  }) => $apply(
    FieldCopyWithData({
      if (addServerResult != null) #addServerResult: addServerResult,
      if (name != null) #name: name,
      if (address != null) #address: address,
      if (port != null) #port: port,
      if (password != null) #password: password,
      if (enableManagement != null) #enableManagement: enableManagement,
      if (sshHost != null) #sshHost: sshHost,
      if (sshPort != null) #sshPort: sshPort,
      if (sshUser != null) #sshUser: sshUser,
      if (isSelectingPrivateKey != null)
        #isSelectingPrivateKey: isSelectingPrivateKey,
      if (privateKeyDisplayName != $none)
        #privateKeyDisplayName: privateKeyDisplayName,
      if (privateKeySelectionError != $none)
        #privateKeySelectionError: privateKeySelectionError,
      if (hostKeyFingerprint != null) #hostKeyFingerprint: hostKeyFingerprint,
    }),
  );
  @override
  AddServerDialogState $make(CopyWithData data) => AddServerDialogState(
    addServerResult: data.get(#addServerResult, or: $value.addServerResult),
    name: data.get(#name, or: $value.name),
    address: data.get(#address, or: $value.address),
    port: data.get(#port, or: $value.port),
    password: data.get(#password, or: $value.password),
    enableManagement: data.get(#enableManagement, or: $value.enableManagement),
    sshHost: data.get(#sshHost, or: $value.sshHost),
    sshPort: data.get(#sshPort, or: $value.sshPort),
    sshUser: data.get(#sshUser, or: $value.sshUser),
    isSelectingPrivateKey: data.get(
      #isSelectingPrivateKey,
      or: $value.isSelectingPrivateKey,
    ),
    privateKeyDisplayName: data.get(
      #privateKeyDisplayName,
      or: $value.privateKeyDisplayName,
    ),
    privateKeySelectionError: data.get(
      #privateKeySelectionError,
      or: $value.privateKeySelectionError,
    ),
    hostKeyFingerprint: data.get(
      #hostKeyFingerprint,
      or: $value.hostKeyFingerprint,
    ),
  );

  @override
  AddServerDialogStateCopyWith<$R2, AddServerDialogState, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AddServerDialogStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

