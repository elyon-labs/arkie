// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'server_info_state.dart';

class ServerInfoStateMapper extends ClassMapperBase<ServerInfoState> {
  ServerInfoStateMapper._();

  static ServerInfoStateMapper? _instance;
  static ServerInfoStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServerInfoStateMapper._());
      ServerStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ServerInfoState';

  static Async<ServerStatus> _$status(ServerInfoState v) => v.status;
  static const Field<ServerInfoState, Async<ServerStatus>> _f$status = Field(
    'status',
    _$status,
  );
  static List<CS2Map> _$maps(ServerInfoState v) => v.maps;
  static const Field<ServerInfoState, List<CS2Map>> _f$maps = Field(
    'maps',
    _$maps,
  );
  static List<WorkshopMap> _$workshopMaps(ServerInfoState v) => v.workshopMaps;
  static const Field<ServerInfoState, List<WorkshopMap>> _f$workshopMaps =
      Field('workshopMaps', _$workshopMaps);
  static Option<PendingAction> _$pendingAction(ServerInfoState v) =>
      v.pendingAction;
  static const Field<ServerInfoState, Option<PendingAction>> _f$pendingAction =
      Field('pendingAction', _$pendingAction);

  @override
  final MappableFields<ServerInfoState> fields = const {
    #status: _f$status,
    #maps: _f$maps,
    #workshopMaps: _f$workshopMaps,
    #pendingAction: _f$pendingAction,
  };

  static ServerInfoState _instantiate(DecodingData data) {
    return ServerInfoState(
      status: data.dec(_f$status),
      maps: data.dec(_f$maps),
      workshopMaps: data.dec(_f$workshopMaps),
      pendingAction: data.dec(_f$pendingAction),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServerInfoState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServerInfoState>(map);
  }

  static ServerInfoState fromJson(String json) {
    return ensureInitialized().decodeJson<ServerInfoState>(json);
  }
}

mixin ServerInfoStateMappable {
  String toJson() {
    return ServerInfoStateMapper.ensureInitialized()
        .encodeJson<ServerInfoState>(this as ServerInfoState);
  }

  Map<String, dynamic> toMap() {
    return ServerInfoStateMapper.ensureInitialized().encodeMap<ServerInfoState>(
      this as ServerInfoState,
    );
  }

  ServerInfoStateCopyWith<ServerInfoState, ServerInfoState, ServerInfoState>
  get copyWith =>
      _ServerInfoStateCopyWithImpl<ServerInfoState, ServerInfoState>(
        this as ServerInfoState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ServerInfoStateMapper.ensureInitialized().stringifyValue(
      this as ServerInfoState,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServerInfoStateMapper.ensureInitialized().equalsValue(
      this as ServerInfoState,
      other,
    );
  }

  @override
  int get hashCode {
    return ServerInfoStateMapper.ensureInitialized().hashValue(
      this as ServerInfoState,
    );
  }
}

extension ServerInfoStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServerInfoState, $Out> {
  ServerInfoStateCopyWith<$R, ServerInfoState, $Out> get $asServerInfoState =>
      $base.as((v, t, t2) => _ServerInfoStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServerInfoStateCopyWith<$R, $In extends ServerInfoState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, CS2Map, ObjectCopyWith<$R, CS2Map, CS2Map>> get maps;
  ListCopyWith<$R, WorkshopMap, ObjectCopyWith<$R, WorkshopMap, WorkshopMap>>
  get workshopMaps;
  $R call({
    Async<ServerStatus>? status,
    List<CS2Map>? maps,
    List<WorkshopMap>? workshopMaps,
    Option<PendingAction>? pendingAction,
  });
  ServerInfoStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ServerInfoStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServerInfoState, $Out>
    implements ServerInfoStateCopyWith<$R, ServerInfoState, $Out> {
  _ServerInfoStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServerInfoState> $mapper =
      ServerInfoStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, CS2Map, ObjectCopyWith<$R, CS2Map, CS2Map>> get maps =>
      ListCopyWith(
        $value.maps,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(maps: v),
      );
  @override
  ListCopyWith<$R, WorkshopMap, ObjectCopyWith<$R, WorkshopMap, WorkshopMap>>
  get workshopMaps => ListCopyWith(
    $value.workshopMaps,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(workshopMaps: v),
  );
  @override
  $R call({
    Async<ServerStatus>? status,
    List<CS2Map>? maps,
    List<WorkshopMap>? workshopMaps,
    Option<PendingAction>? pendingAction,
  }) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (maps != null) #maps: maps,
      if (workshopMaps != null) #workshopMaps: workshopMaps,
      if (pendingAction != null) #pendingAction: pendingAction,
    }),
  );
  @override
  ServerInfoState $make(CopyWithData data) => ServerInfoState(
    status: data.get(#status, or: $value.status),
    maps: data.get(#maps, or: $value.maps),
    workshopMaps: data.get(#workshopMaps, or: $value.workshopMaps),
    pendingAction: data.get(#pendingAction, or: $value.pendingAction),
  );

  @override
  ServerInfoStateCopyWith<$R2, ServerInfoState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServerInfoStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

