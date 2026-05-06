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

  @override
  final MappableFields<ServersState> fields = const {
    #servers: _f$servers,
    #openTabs: _f$openTabs,
    #selectedTabId: _f$selectedTabId,
    #selectedTab: _f$selectedTab,
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
      EmptyServerTabMapper.ensureInitialized();
      NonEmptyServerTabMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OpenServerTab';

  static String _$id(OpenServerTab v) => v.id;
  static const Field<OpenServerTab, String> _f$id = Field('id', _$id);

  @override
  final MappableFields<OpenServerTab> fields = const {#id: _f$id};

  static OpenServerTab _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'OpenServerTab',
      'type',
      '${data.value['type']}',
    );
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
  String toJson();
  Map<String, dynamic> toMap();
  OpenServerTabCopyWith<OpenServerTab, OpenServerTab, OpenServerTab>
  get copyWith;
}

abstract class OpenServerTabCopyWith<$R, $In extends OpenServerTab, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id});
  OpenServerTabCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class EmptyServerTabMapper extends SubClassMapperBase<EmptyServerTab> {
  EmptyServerTabMapper._();

  static EmptyServerTabMapper? _instance;
  static EmptyServerTabMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EmptyServerTabMapper._());
      OpenServerTabMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'EmptyServerTab';

  static String _$id(EmptyServerTab v) => v.id;
  static const Field<EmptyServerTab, String> _f$id = Field('id', _$id);

  @override
  final MappableFields<EmptyServerTab> fields = const {#id: _f$id};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'EmptyServerTab';
  @override
  late final ClassMapperBase superMapper =
      OpenServerTabMapper.ensureInitialized();

  static EmptyServerTab _instantiate(DecodingData data) {
    return EmptyServerTab(id: data.dec(_f$id));
  }

  @override
  final Function instantiate = _instantiate;

  static EmptyServerTab fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EmptyServerTab>(map);
  }

  static EmptyServerTab fromJson(String json) {
    return ensureInitialized().decodeJson<EmptyServerTab>(json);
  }
}

mixin EmptyServerTabMappable {
  String toJson() {
    return EmptyServerTabMapper.ensureInitialized().encodeJson<EmptyServerTab>(
      this as EmptyServerTab,
    );
  }

  Map<String, dynamic> toMap() {
    return EmptyServerTabMapper.ensureInitialized().encodeMap<EmptyServerTab>(
      this as EmptyServerTab,
    );
  }

  EmptyServerTabCopyWith<EmptyServerTab, EmptyServerTab, EmptyServerTab>
  get copyWith => _EmptyServerTabCopyWithImpl<EmptyServerTab, EmptyServerTab>(
    this as EmptyServerTab,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return EmptyServerTabMapper.ensureInitialized().stringifyValue(
      this as EmptyServerTab,
    );
  }

  @override
  bool operator ==(Object other) {
    return EmptyServerTabMapper.ensureInitialized().equalsValue(
      this as EmptyServerTab,
      other,
    );
  }

  @override
  int get hashCode {
    return EmptyServerTabMapper.ensureInitialized().hashValue(
      this as EmptyServerTab,
    );
  }
}

extension EmptyServerTabValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EmptyServerTab, $Out> {
  EmptyServerTabCopyWith<$R, EmptyServerTab, $Out> get $asEmptyServerTab =>
      $base.as((v, t, t2) => _EmptyServerTabCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EmptyServerTabCopyWith<$R, $In extends EmptyServerTab, $Out>
    implements OpenServerTabCopyWith<$R, $In, $Out> {
  @override
  $R call({String? id});
  EmptyServerTabCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EmptyServerTabCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EmptyServerTab, $Out>
    implements EmptyServerTabCopyWith<$R, EmptyServerTab, $Out> {
  _EmptyServerTabCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EmptyServerTab> $mapper =
      EmptyServerTabMapper.ensureInitialized();
  @override
  $R call({String? id}) => $apply(FieldCopyWithData({if (id != null) #id: id}));
  @override
  EmptyServerTab $make(CopyWithData data) =>
      EmptyServerTab(id: data.get(#id, or: $value.id));

  @override
  EmptyServerTabCopyWith<$R2, EmptyServerTab, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EmptyServerTabCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class NonEmptyServerTabMapper extends SubClassMapperBase<NonEmptyServerTab> {
  NonEmptyServerTabMapper._();

  static NonEmptyServerTabMapper? _instance;
  static NonEmptyServerTabMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NonEmptyServerTabMapper._());
      OpenServerTabMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'NonEmptyServerTab';

  static String _$id(NonEmptyServerTab v) => v.id;
  static const Field<NonEmptyServerTab, String> _f$id = Field('id', _$id);
  static String _$serverId(NonEmptyServerTab v) => v.serverId;
  static const Field<NonEmptyServerTab, String> _f$serverId = Field(
    'serverId',
    _$serverId,
  );

  @override
  final MappableFields<NonEmptyServerTab> fields = const {
    #id: _f$id,
    #serverId: _f$serverId,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'NonEmptyServerTab';
  @override
  late final ClassMapperBase superMapper =
      OpenServerTabMapper.ensureInitialized();

  static NonEmptyServerTab _instantiate(DecodingData data) {
    return NonEmptyServerTab(
      id: data.dec(_f$id),
      serverId: data.dec(_f$serverId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static NonEmptyServerTab fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<NonEmptyServerTab>(map);
  }

  static NonEmptyServerTab fromJson(String json) {
    return ensureInitialized().decodeJson<NonEmptyServerTab>(json);
  }
}

mixin NonEmptyServerTabMappable {
  String toJson() {
    return NonEmptyServerTabMapper.ensureInitialized()
        .encodeJson<NonEmptyServerTab>(this as NonEmptyServerTab);
  }

  Map<String, dynamic> toMap() {
    return NonEmptyServerTabMapper.ensureInitialized()
        .encodeMap<NonEmptyServerTab>(this as NonEmptyServerTab);
  }

  NonEmptyServerTabCopyWith<
    NonEmptyServerTab,
    NonEmptyServerTab,
    NonEmptyServerTab
  >
  get copyWith =>
      _NonEmptyServerTabCopyWithImpl<NonEmptyServerTab, NonEmptyServerTab>(
        this as NonEmptyServerTab,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return NonEmptyServerTabMapper.ensureInitialized().stringifyValue(
      this as NonEmptyServerTab,
    );
  }

  @override
  bool operator ==(Object other) {
    return NonEmptyServerTabMapper.ensureInitialized().equalsValue(
      this as NonEmptyServerTab,
      other,
    );
  }

  @override
  int get hashCode {
    return NonEmptyServerTabMapper.ensureInitialized().hashValue(
      this as NonEmptyServerTab,
    );
  }
}

extension NonEmptyServerTabValueCopy<$R, $Out>
    on ObjectCopyWith<$R, NonEmptyServerTab, $Out> {
  NonEmptyServerTabCopyWith<$R, NonEmptyServerTab, $Out>
  get $asNonEmptyServerTab => $base.as(
    (v, t, t2) => _NonEmptyServerTabCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class NonEmptyServerTabCopyWith<
  $R,
  $In extends NonEmptyServerTab,
  $Out
>
    implements OpenServerTabCopyWith<$R, $In, $Out> {
  @override
  $R call({String? id, String? serverId});
  NonEmptyServerTabCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _NonEmptyServerTabCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, NonEmptyServerTab, $Out>
    implements NonEmptyServerTabCopyWith<$R, NonEmptyServerTab, $Out> {
  _NonEmptyServerTabCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<NonEmptyServerTab> $mapper =
      NonEmptyServerTabMapper.ensureInitialized();
  @override
  $R call({String? id, String? serverId}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (serverId != null) #serverId: serverId,
    }),
  );
  @override
  NonEmptyServerTab $make(CopyWithData data) => NonEmptyServerTab(
    id: data.get(#id, or: $value.id),
    serverId: data.get(#serverId, or: $value.serverId),
  );

  @override
  NonEmptyServerTabCopyWith<$R2, NonEmptyServerTab, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _NonEmptyServerTabCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

