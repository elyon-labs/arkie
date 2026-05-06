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
      OpenServerTabMapper.ensureInitialized();
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
  static List<OpenServerTab> _$openTabs(ServersState v) => v.openTabs;
  static const Field<ServersState, List<OpenServerTab>> _f$openTabs = Field(
    'openTabs',
    _$openTabs,
  );
  static String? _$selectedTabId(ServersState v) => v.selectedTabId;
  static const Field<ServersState, String> _f$selectedTabId = Field(
    'selectedTabId',
    _$selectedTabId,
  );
  static OpenServerTab? _$selectedTab(ServersState v) => v.selectedTab;
  static const Field<ServersState, OpenServerTab> _f$selectedTab = Field(
    'selectedTab',
    _$selectedTab,
    mode: FieldMode.member,
  );
  static Server? _$selectedServer(ServersState v) => v.selectedServer;
  static const Field<ServersState, Server> _f$selectedServer = Field(
    'selectedServer',
    _$selectedServer,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<ServersState> fields = const {
    #servers: _f$servers,
    #openTabs: _f$openTabs,
    #selectedTabId: _f$selectedTabId,
    #selectedTab: _f$selectedTab,
    #selectedServer: _f$selectedServer,
  };

  static ServersState _instantiate(DecodingData data) {
    return ServersState(
      servers: data.dec(_f$servers),
      openTabs: data.dec(_f$openTabs),
      selectedTabId: data.dec(_f$selectedTabId),
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
  ListCopyWith<
    $R,
    OpenServerTab,
    OpenServerTabCopyWith<$R, OpenServerTab, OpenServerTab>
  >
  get openTabs;
  $R call({
    List<Server>? servers,
    List<OpenServerTab>? openTabs,
    String? selectedTabId,
  });
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
  ListCopyWith<
    $R,
    OpenServerTab,
    OpenServerTabCopyWith<$R, OpenServerTab, OpenServerTab>
  >
  get openTabs => ListCopyWith(
    $value.openTabs,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(openTabs: v),
  );
  @override
  $R call({
    List<Server>? servers,
    List<OpenServerTab>? openTabs,
    Object? selectedTabId = $none,
  }) => $apply(
    FieldCopyWithData({
      if (servers != null) #servers: servers,
      if (openTabs != null) #openTabs: openTabs,
      if (selectedTabId != $none) #selectedTabId: selectedTabId,
    }),
  );
  @override
  ServersState $make(CopyWithData data) => ServersState(
    servers: data.get(#servers, or: $value.servers),
    openTabs: data.get(#openTabs, or: $value.openTabs),
    selectedTabId: data.get(#selectedTabId, or: $value.selectedTabId),
  );

  @override
  ServersStateCopyWith<$R2, ServersState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServersStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OpenServerTabMapper extends ClassMapperBase<OpenServerTab> {
  OpenServerTabMapper._();

  static OpenServerTabMapper? _instance;
  static OpenServerTabMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OpenServerTabMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'OpenServerTab';

  static String _$id(OpenServerTab v) => v.id;
  static const Field<OpenServerTab, String> _f$id = Field('id', _$id);
  static String? _$serverId(OpenServerTab v) => v.serverId;
  static const Field<OpenServerTab, String> _f$serverId = Field(
    'serverId',
    _$serverId,
  );
  static bool _$isEmpty(OpenServerTab v) => v.isEmpty;
  static const Field<OpenServerTab, bool> _f$isEmpty = Field(
    'isEmpty',
    _$isEmpty,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<OpenServerTab> fields = const {
    #id: _f$id,
    #serverId: _f$serverId,
    #isEmpty: _f$isEmpty,
  };

  static OpenServerTab _instantiate(DecodingData data) {
    return OpenServerTab(id: data.dec(_f$id), serverId: data.dec(_f$serverId));
  }

  @override
  final Function instantiate = _instantiate;

  static OpenServerTab fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OpenServerTab>(map);
  }

  static OpenServerTab fromJson(String json) {
    return ensureInitialized().decodeJson<OpenServerTab>(json);
  }
}

mixin OpenServerTabMappable {
  String toJson() {
    return OpenServerTabMapper.ensureInitialized().encodeJson<OpenServerTab>(
      this as OpenServerTab,
    );
  }

  Map<String, dynamic> toMap() {
    return OpenServerTabMapper.ensureInitialized().encodeMap<OpenServerTab>(
      this as OpenServerTab,
    );
  }

  OpenServerTabCopyWith<OpenServerTab, OpenServerTab, OpenServerTab>
  get copyWith => _OpenServerTabCopyWithImpl<OpenServerTab, OpenServerTab>(
    this as OpenServerTab,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return OpenServerTabMapper.ensureInitialized().stringifyValue(
      this as OpenServerTab,
    );
  }

  @override
  bool operator ==(Object other) {
    return OpenServerTabMapper.ensureInitialized().equalsValue(
      this as OpenServerTab,
      other,
    );
  }

  @override
  int get hashCode {
    return OpenServerTabMapper.ensureInitialized().hashValue(
      this as OpenServerTab,
    );
  }
}

extension OpenServerTabValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OpenServerTab, $Out> {
  OpenServerTabCopyWith<$R, OpenServerTab, $Out> get $asOpenServerTab =>
      $base.as((v, t, t2) => _OpenServerTabCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OpenServerTabCopyWith<$R, $In extends OpenServerTab, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? serverId});
  OpenServerTabCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OpenServerTabCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OpenServerTab, $Out>
    implements OpenServerTabCopyWith<$R, OpenServerTab, $Out> {
  _OpenServerTabCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OpenServerTab> $mapper =
      OpenServerTabMapper.ensureInitialized();
  @override
  $R call({String? id, Object? serverId = $none}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (serverId != $none) #serverId: serverId,
    }),
  );
  @override
  OpenServerTab $make(CopyWithData data) => OpenServerTab(
    id: data.get(#id, or: $value.id),
    serverId: data.get(#serverId, or: $value.serverId),
  );

  @override
  OpenServerTabCopyWith<$R2, OpenServerTab, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OpenServerTabCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

