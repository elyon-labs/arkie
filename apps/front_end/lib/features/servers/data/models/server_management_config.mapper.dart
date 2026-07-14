// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'server_management_config.dart';

class ServerManagementBackendMapper
    extends EnumMapper<ServerManagementBackend> {
  ServerManagementBackendMapper._();

  static ServerManagementBackendMapper? _instance;
  static ServerManagementBackendMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = ServerManagementBackendMapper._(),
      );
    }
    return _instance!;
  }

  static ServerManagementBackend fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ServerManagementBackend decode(dynamic value) {
    switch (value) {
      case r'systemd':
        return ServerManagementBackend.systemd;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ServerManagementBackend self) {
    switch (self) {
      case ServerManagementBackend.systemd:
        return r'systemd';
    }
  }
}

extension ServerManagementBackendMapperExtension on ServerManagementBackend {
  String toValue() {
    ServerManagementBackendMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ServerManagementBackend>(this)
        as String;
  }
}

class ServerManagementConfigMapper
    extends ClassMapperBase<ServerManagementConfig> {
  ServerManagementConfigMapper._();

  static ServerManagementConfigMapper? _instance;
  static ServerManagementConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServerManagementConfigMapper._());
      ServerManagementBackendMapper.ensureInitialized();
      ManagedPrivateKeyReferenceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ServerManagementConfig';

  static ServerManagementBackend _$backend(ServerManagementConfig v) =>
      v.backend;
  static const Field<ServerManagementConfig, ServerManagementBackend>
  _f$backend = Field('backend', _$backend);
  static String _$sshHost(ServerManagementConfig v) => v.sshHost;
  static const Field<ServerManagementConfig, String> _f$sshHost = Field(
    'sshHost',
    _$sshHost,
  );
  static int _$sshPort(ServerManagementConfig v) => v.sshPort;
  static const Field<ServerManagementConfig, int> _f$sshPort = Field(
    'sshPort',
    _$sshPort,
  );
  static String _$sshUser(ServerManagementConfig v) => v.sshUser;
  static const Field<ServerManagementConfig, String> _f$sshUser = Field(
    'sshUser',
    _$sshUser,
  );
  static String _$hostKeyFingerprint(ServerManagementConfig v) =>
      v.hostKeyFingerprint;
  static const Field<ServerManagementConfig, String> _f$hostKeyFingerprint =
      Field('hostKeyFingerprint', _$hostKeyFingerprint);
  static ManagedPrivateKeyReference? _$privateKey(ServerManagementConfig v) =>
      v.privateKey;
  static const Field<ServerManagementConfig, ManagedPrivateKeyReference>
  _f$privateKey = Field('privateKey', _$privateKey, opt: true);
  static String? _$privateKeyPath(ServerManagementConfig v) => v.privateKeyPath;
  static const Field<ServerManagementConfig, String> _f$privateKeyPath = Field(
    'privateKeyPath',
    _$privateKeyPath,
    opt: true,
  );

  @override
  final MappableFields<ServerManagementConfig> fields = const {
    #backend: _f$backend,
    #sshHost: _f$sshHost,
    #sshPort: _f$sshPort,
    #sshUser: _f$sshUser,
    #hostKeyFingerprint: _f$hostKeyFingerprint,
    #privateKey: _f$privateKey,
    #privateKeyPath: _f$privateKeyPath,
  };

  static ServerManagementConfig _instantiate(DecodingData data) {
    return ServerManagementConfig(
      backend: data.dec(_f$backend),
      sshHost: data.dec(_f$sshHost),
      sshPort: data.dec(_f$sshPort),
      sshUser: data.dec(_f$sshUser),
      hostKeyFingerprint: data.dec(_f$hostKeyFingerprint),
      privateKey: data.dec(_f$privateKey),
      privateKeyPath: data.dec(_f$privateKeyPath),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServerManagementConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServerManagementConfig>(map);
  }

  static ServerManagementConfig fromJson(String json) {
    return ensureInitialized().decodeJson<ServerManagementConfig>(json);
  }
}

mixin ServerManagementConfigMappable {
  String toJson() {
    return ServerManagementConfigMapper.ensureInitialized()
        .encodeJson<ServerManagementConfig>(this as ServerManagementConfig);
  }

  Map<String, dynamic> toMap() {
    return ServerManagementConfigMapper.ensureInitialized()
        .encodeMap<ServerManagementConfig>(this as ServerManagementConfig);
  }

  ServerManagementConfigCopyWith<
    ServerManagementConfig,
    ServerManagementConfig,
    ServerManagementConfig
  >
  get copyWith =>
      _ServerManagementConfigCopyWithImpl<
        ServerManagementConfig,
        ServerManagementConfig
      >(this as ServerManagementConfig, $identity, $identity);
  @override
  String toString() {
    return ServerManagementConfigMapper.ensureInitialized().stringifyValue(
      this as ServerManagementConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServerManagementConfigMapper.ensureInitialized().equalsValue(
      this as ServerManagementConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return ServerManagementConfigMapper.ensureInitialized().hashValue(
      this as ServerManagementConfig,
    );
  }
}

extension ServerManagementConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServerManagementConfig, $Out> {
  ServerManagementConfigCopyWith<$R, ServerManagementConfig, $Out>
  get $asServerManagementConfig => $base.as(
    (v, t, t2) => _ServerManagementConfigCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ServerManagementConfigCopyWith<
  $R,
  $In extends ServerManagementConfig,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ManagedPrivateKeyReferenceCopyWith<
    $R,
    ManagedPrivateKeyReference,
    ManagedPrivateKeyReference
  >?
  get privateKey;
  $R call({
    ServerManagementBackend? backend,
    String? sshHost,
    int? sshPort,
    String? sshUser,
    String? hostKeyFingerprint,
    ManagedPrivateKeyReference? privateKey,
    String? privateKeyPath,
  });
  ServerManagementConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ServerManagementConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServerManagementConfig, $Out>
    implements
        ServerManagementConfigCopyWith<$R, ServerManagementConfig, $Out> {
  _ServerManagementConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServerManagementConfig> $mapper =
      ServerManagementConfigMapper.ensureInitialized();
  @override
  ManagedPrivateKeyReferenceCopyWith<
    $R,
    ManagedPrivateKeyReference,
    ManagedPrivateKeyReference
  >?
  get privateKey =>
      $value.privateKey?.copyWith.$chain((v) => call(privateKey: v));
  @override
  $R call({
    ServerManagementBackend? backend,
    String? sshHost,
    int? sshPort,
    String? sshUser,
    String? hostKeyFingerprint,
    Object? privateKey = $none,
    Object? privateKeyPath = $none,
  }) => $apply(
    FieldCopyWithData({
      if (backend != null) #backend: backend,
      if (sshHost != null) #sshHost: sshHost,
      if (sshPort != null) #sshPort: sshPort,
      if (sshUser != null) #sshUser: sshUser,
      if (hostKeyFingerprint != null) #hostKeyFingerprint: hostKeyFingerprint,
      if (privateKey != $none) #privateKey: privateKey,
      if (privateKeyPath != $none) #privateKeyPath: privateKeyPath,
    }),
  );
  @override
  ServerManagementConfig $make(CopyWithData data) => ServerManagementConfig(
    backend: data.get(#backend, or: $value.backend),
    sshHost: data.get(#sshHost, or: $value.sshHost),
    sshPort: data.get(#sshPort, or: $value.sshPort),
    sshUser: data.get(#sshUser, or: $value.sshUser),
    hostKeyFingerprint: data.get(
      #hostKeyFingerprint,
      or: $value.hostKeyFingerprint,
    ),
    privateKey: data.get(#privateKey, or: $value.privateKey),
    privateKeyPath: data.get(#privateKeyPath, or: $value.privateKeyPath),
  );

  @override
  ServerManagementConfigCopyWith<$R2, ServerManagementConfig, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ServerManagementConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

