// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'server.dart';

class ServerMapper extends ClassMapperBase<Server> {
  ServerMapper._();

  static ServerMapper? _instance;
  static ServerMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServerMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Server';

  static String _$id(Server v) => v.id;
  static const Field<Server, String> _f$id = Field('id', _$id);
  static String _$name(Server v) => v.name;
  static const Field<Server, String> _f$name = Field('name', _$name);
  static String _$password(Server v) => v.password;
  static const Field<Server, String> _f$password = Field(
    'password',
    _$password,
  );
  static String _$address(Server v) => v.address;
  static const Field<Server, String> _f$address = Field('address', _$address);
  static int _$port(Server v) => v.port;
  static const Field<Server, int> _f$port = Field('port', _$port);

  @override
  final MappableFields<Server> fields = const {
    #id: _f$id,
    #name: _f$name,
    #password: _f$password,
    #address: _f$address,
    #port: _f$port,
  };

  static Server _instantiate(DecodingData data) {
    return Server(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      password: data.dec(_f$password),
      address: data.dec(_f$address),
      port: data.dec(_f$port),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Server fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Server>(map);
  }

  static Server fromJson(String json) {
    return ensureInitialized().decodeJson<Server>(json);
  }
}

mixin ServerMappable {
  String toJson() {
    return ServerMapper.ensureInitialized().encodeJson<Server>(this as Server);
  }

  Map<String, dynamic> toMap() {
    return ServerMapper.ensureInitialized().encodeMap<Server>(this as Server);
  }

  ServerCopyWith<Server, Server, Server> get copyWith =>
      _ServerCopyWithImpl<Server, Server>(this as Server, $identity, $identity);
  @override
  String toString() {
    return ServerMapper.ensureInitialized().stringifyValue(this as Server);
  }

  @override
  bool operator ==(Object other) {
    return ServerMapper.ensureInitialized().equalsValue(this as Server, other);
  }

  @override
  int get hashCode {
    return ServerMapper.ensureInitialized().hashValue(this as Server);
  }
}

extension ServerValueCopy<$R, $Out> on ObjectCopyWith<$R, Server, $Out> {
  ServerCopyWith<$R, Server, $Out> get $asServer =>
      $base.as((v, t, t2) => _ServerCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServerCopyWith<$R, $In extends Server, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? password,
    String? address,
    int? port,
  });
  ServerCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ServerCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Server, $Out>
    implements ServerCopyWith<$R, Server, $Out> {
  _ServerCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Server> $mapper = ServerMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? password,
    String? address,
    int? port,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (password != null) #password: password,
      if (address != null) #address: address,
      if (port != null) #port: port,
    }),
  );
  @override
  Server $make(CopyWithData data) => Server(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    password: data.get(#password, or: $value.password),
    address: data.get(#address, or: $value.address),
    port: data.get(#port, or: $value.port),
  );

  @override
  ServerCopyWith<$R2, Server, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ServerCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

