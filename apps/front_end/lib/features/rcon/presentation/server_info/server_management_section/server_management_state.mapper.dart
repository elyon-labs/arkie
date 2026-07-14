// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'server_management_state.dart';

class ServerManagementStateMapper
    extends ClassMapperBase<ServerManagementState> {
  ServerManagementStateMapper._();

  static ServerManagementStateMapper? _instance;
  static ServerManagementStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServerManagementStateMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ServerManagementState';

  static bool _$isBusy(ServerManagementState v) => v.isBusy;
  static const Field<ServerManagementState, bool> _f$isBusy = Field(
    'isBusy',
    _$isBusy,
  );
  static bool _$isStreamingLogs(ServerManagementState v) => v.isStreamingLogs;
  static const Field<ServerManagementState, bool> _f$isStreamingLogs = Field(
    'isStreamingLogs',
    _$isStreamingLogs,
  );
  static String? _$status(ServerManagementState v) => v.status;
  static const Field<ServerManagementState, String> _f$status = Field(
    'status',
    _$status,
  );
  static List<String> _$logs(ServerManagementState v) => v.logs;
  static const Field<ServerManagementState, List<String>> _f$logs = Field(
    'logs',
    _$logs,
  );

  @override
  final MappableFields<ServerManagementState> fields = const {
    #isBusy: _f$isBusy,
    #isStreamingLogs: _f$isStreamingLogs,
    #status: _f$status,
    #logs: _f$logs,
  };

  static ServerManagementState _instantiate(DecodingData data) {
    return ServerManagementState(
      isBusy: data.dec(_f$isBusy),
      isStreamingLogs: data.dec(_f$isStreamingLogs),
      status: data.dec(_f$status),
      logs: data.dec(_f$logs),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServerManagementState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServerManagementState>(map);
  }

  static ServerManagementState fromJson(String json) {
    return ensureInitialized().decodeJson<ServerManagementState>(json);
  }
}

mixin ServerManagementStateMappable {
  String toJson() {
    return ServerManagementStateMapper.ensureInitialized()
        .encodeJson<ServerManagementState>(this as ServerManagementState);
  }

  Map<String, dynamic> toMap() {
    return ServerManagementStateMapper.ensureInitialized()
        .encodeMap<ServerManagementState>(this as ServerManagementState);
  }

  ServerManagementStateCopyWith<
    ServerManagementState,
    ServerManagementState,
    ServerManagementState
  >
  get copyWith =>
      _ServerManagementStateCopyWithImpl<
        ServerManagementState,
        ServerManagementState
      >(this as ServerManagementState, $identity, $identity);
  @override
  String toString() {
    return ServerManagementStateMapper.ensureInitialized().stringifyValue(
      this as ServerManagementState,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServerManagementStateMapper.ensureInitialized().equalsValue(
      this as ServerManagementState,
      other,
    );
  }

  @override
  int get hashCode {
    return ServerManagementStateMapper.ensureInitialized().hashValue(
      this as ServerManagementState,
    );
  }
}

extension ServerManagementStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServerManagementState, $Out> {
  ServerManagementStateCopyWith<$R, ServerManagementState, $Out>
  get $asServerManagementState => $base.as(
    (v, t, t2) => _ServerManagementStateCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ServerManagementStateCopyWith<
  $R,
  $In extends ServerManagementState,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get logs;
  $R call({
    bool? isBusy,
    bool? isStreamingLogs,
    String? status,
    List<String>? logs,
  });
  ServerManagementStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ServerManagementStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServerManagementState, $Out>
    implements ServerManagementStateCopyWith<$R, ServerManagementState, $Out> {
  _ServerManagementStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServerManagementState> $mapper =
      ServerManagementStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get logs =>
      ListCopyWith(
        $value.logs,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(logs: v),
      );
  @override
  $R call({
    bool? isBusy,
    bool? isStreamingLogs,
    Object? status = $none,
    List<String>? logs,
  }) => $apply(
    FieldCopyWithData({
      if (isBusy != null) #isBusy: isBusy,
      if (isStreamingLogs != null) #isStreamingLogs: isStreamingLogs,
      if (status != $none) #status: status,
      if (logs != null) #logs: logs,
    }),
  );
  @override
  ServerManagementState $make(CopyWithData data) => ServerManagementState(
    isBusy: data.get(#isBusy, or: $value.isBusy),
    isStreamingLogs: data.get(#isStreamingLogs, or: $value.isStreamingLogs),
    status: data.get(#status, or: $value.status),
    logs: data.get(#logs, or: $value.logs),
  );

  @override
  ServerManagementStateCopyWith<$R2, ServerManagementState, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ServerManagementStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

