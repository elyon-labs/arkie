// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'servers_state.dart';

class ServersStateMapper extends ClassMapperBase<ServersState> {
  ServersStateMapper._();

  static ServersStateMapper? _instance;
  static ServersStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServersStateMapper._());
      ServerMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ServersState';

  static List<Server> _$servers(ServersState v) => v.servers;
  static const Field<ServersState, List<Server>> _f$servers = Field(
    'servers',
    _$servers,
  );
  static Server? _$selectedServer(ServersState v) => v.selectedServer;
  static const Field<ServersState, Server> _f$selectedServer = Field(
    'selectedServer',
    _$selectedServer,
  );

  @override
  final MappableFields<ServersState> fields = const {
    #servers: _f$servers,
    #selectedServer: _f$selectedServer,
  };

  static ServersState _instantiate(DecodingData data) {
    return ServersState(
      servers: data.dec(_f$servers),
      selectedServer: data.dec(_f$selectedServer),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServersState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServersState>(map);
  }

  static ServersState fromJson(String json) {
    return ensureInitialized().decodeJson<ServersState>(json);
  }
}

mixin ServersStateMappable {
  String toJson() {
    return ServersStateMapper.ensureInitialized().encodeJson<ServersState>(
      this as ServersState,
    );
  }

  Map<String, dynamic> toMap() {
    return ServersStateMapper.ensureInitialized().encodeMap<ServersState>(
      this as ServersState,
    );
  }

  ServersStateCopyWith<ServersState, ServersState, ServersState> get copyWith =>
      _ServersStateCopyWithImpl<ServersState, ServersState>(
        this as ServersState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ServersStateMapper.ensureInitialized().stringifyValue(
      this as ServersState,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServersStateMapper.ensureInitialized().equalsValue(
      this as ServersState,
      other,
    );
  }

  @override
  int get hashCode {
    return ServersStateMapper.ensureInitialized().hashValue(
      this as ServersState,
    );
  }
}

extension ServersStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServersState, $Out> {
  ServersStateCopyWith<$R, ServersState, $Out> get $asServersState =>
      $base.as((v, t, t2) => _ServersStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServersStateCopyWith<$R, $In extends ServersState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Server, ServerCopyWith<$R, Server, Server>> get servers;
  ServerCopyWith<$R, Server, Server>? get selectedServer;
  $R call({List<Server>? servers, Server? selectedServer});
  ServersStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ServersStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServersState, $Out>
    implements ServersStateCopyWith<$R, ServersState, $Out> {
  _ServersStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServersState> $mapper =
      ServersStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Server, ServerCopyWith<$R, Server, Server>> get servers =>
      ListCopyWith(
        $value.servers,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(servers: v),
      );
  @override
  ServerCopyWith<$R, Server, Server>? get selectedServer =>
      $value.selectedServer?.copyWith.$chain((v) => call(selectedServer: v));
  @override
  $R call({List<Server>? servers, Object? selectedServer = $none}) => $apply(
    FieldCopyWithData({
      if (servers != null) #servers: servers,
      if (selectedServer != $none) #selectedServer: selectedServer,
    }),
  );
  @override
  ServersState $make(CopyWithData data) => ServersState(
    servers: data.get(#servers, or: $value.servers),
    selectedServer: data.get(#selectedServer, or: $value.selectedServer),
  );

  @override
  ServersStateCopyWith<$R2, ServersState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServersStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

