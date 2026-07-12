// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint

part of 'server_management_config.dart';

class ServerManagementBackendMapper extends EnumMapper<ServerManagementBackend> {
  ServerManagementBackendMapper._();
  static ServerManagementBackendMapper? _instance;
  static ServerManagementBackendMapper ensureInitialized() {
    if (_instance == null) MapperContainer.globals.use(_instance = ServerManagementBackendMapper._());
    return _instance!;
  }
  static ServerManagementBackend fromValue(String value) => ensureInitialized().decode(value);
  @override final String id = 'ServerManagementBackend';
  @override final Map<ServerManagementBackend, String> values = const {ServerManagementBackend.systemd: 'systemd'};
}

extension ServerManagementBackendMapperExtension on ServerManagementBackend {
  String toValue() => ServerManagementBackendMapper.ensureInitialized().encode(this);
}

class ServerManagementConfigMapper extends ClassMapperBase<ServerManagementConfig> {
  ServerManagementConfigMapper._();
  static ServerManagementConfigMapper? _instance;
  static ServerManagementConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServerManagementConfigMapper._());
      ServerManagementBackendMapper.ensureInitialized();
    }
    return _instance!;
  }
  @override final String id = 'ServerManagementConfig';
  static ServerManagementBackend _$backend(ServerManagementConfig v) => v.backend;
  static const Field<ServerManagementConfig, ServerManagementBackend> _f$backend = Field('backend', _$backend);
  static String _$sshHost(ServerManagementConfig v) => v.sshHost;
  static const Field<ServerManagementConfig, String> _f$sshHost = Field('sshHost', _$sshHost);
  static int _$sshPort(ServerManagementConfig v) => v.sshPort;
  static const Field<ServerManagementConfig, int> _f$sshPort = Field('sshPort', _$sshPort);
  static String _$sshUser(ServerManagementConfig v) => v.sshUser;
  static const Field<ServerManagementConfig, String> _f$sshUser = Field('sshUser', _$sshUser);
  static String _$privateKeyPath(ServerManagementConfig v) => v.privateKeyPath;
  static const Field<ServerManagementConfig, String> _f$privateKeyPath = Field('privateKeyPath', _$privateKeyPath);
  static String _$hostKeyFingerprint(ServerManagementConfig v) => v.hostKeyFingerprint;
  static const Field<ServerManagementConfig, String> _f$hostKeyFingerprint = Field('hostKeyFingerprint', _$hostKeyFingerprint);
  @override final MappableFields<ServerManagementConfig> fields = const {#backend: _f$backend, #sshHost: _f$sshHost, #sshPort: _f$sshPort, #sshUser: _f$sshUser, #privateKeyPath: _f$privateKeyPath, #hostKeyFingerprint: _f$hostKeyFingerprint};
  static ServerManagementConfig _instantiate(DecodingData data) => ServerManagementConfig(backend: data.dec(_f$backend), sshHost: data.dec(_f$sshHost), sshPort: data.dec(_f$sshPort), sshUser: data.dec(_f$sshUser), privateKeyPath: data.dec(_f$privateKeyPath), hostKeyFingerprint: data.dec(_f$hostKeyFingerprint));
  @override final Function instantiate = _instantiate;
}

mixin ServerManagementConfigMappable {
  String toJson() => ServerManagementConfigMapper.ensureInitialized().encodeJson<ServerManagementConfig>(this as ServerManagementConfig);
  Map<String, dynamic> toMap() => ServerManagementConfigMapper.ensureInitialized().encodeMap<ServerManagementConfig>(this as ServerManagementConfig);
  ServerManagementConfigCopyWith<ServerManagementConfig, ServerManagementConfig, ServerManagementConfig> get copyWith => _ServerManagementConfigCopyWithImpl<ServerManagementConfig, ServerManagementConfig>(this as ServerManagementConfig, $identity, $identity);
}

abstract class ServerManagementConfigCopyWith<$R, $In extends ServerManagementConfig, $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({ServerManagementBackend? backend, String? sshHost, int? sshPort, String? sshUser, String? privateKeyPath, String? hostKeyFingerprint});
  ServerManagementConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ServerManagementConfigCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, ServerManagementConfig, $Out> implements ServerManagementConfigCopyWith<$R, ServerManagementConfig, $Out> {
  _ServerManagementConfigCopyWithImpl(super.value, super.then, super.then2);
  @override late final ClassMapperBase<ServerManagementConfig> $mapper = ServerManagementConfigMapper.ensureInitialized();
  @override $R call({ServerManagementBackend? backend, String? sshHost, int? sshPort, String? sshUser, String? privateKeyPath, String? hostKeyFingerprint}) => $apply(FieldCopyWithData({if (backend != null) #backend: backend, if (sshHost != null) #sshHost: sshHost, if (sshPort != null) #sshPort: sshPort, if (sshUser != null) #sshUser: sshUser, if (privateKeyPath != null) #privateKeyPath: privateKeyPath, if (hostKeyFingerprint != null) #hostKeyFingerprint: hostKeyFingerprint}));
  @override ServerManagementConfig $make(CopyWithData data) => ServerManagementConfig(backend: data.get(#backend, or: $value.backend), sshHost: data.get(#sshHost, or: $value.sshHost), sshPort: data.get(#sshPort, or: $value.sshPort), sshUser: data.get(#sshUser, or: $value.sshUser), privateKeyPath: data.get(#privateKeyPath, or: $value.privateKeyPath), hostKeyFingerprint: data.get(#hostKeyFingerprint, or: $value.hostKeyFingerprint));
  @override ServerManagementConfigCopyWith<$R2, ServerManagementConfig, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) => _ServerManagementConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
