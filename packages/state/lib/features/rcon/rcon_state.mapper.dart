// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'rcon_state.dart';

class RCONStateMapper extends ClassMapperBase<RCONState> {
  RCONStateMapper._();

  static RCONStateMapper? _instance;
  static RCONStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RCONStateMapper._());
      ServerMapper.ensureInitialized();
      SavedMessageMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'RCONState';

  static Server _$server(RCONState v) => v.server;
  static const Field<RCONState, Server> _f$server = Field('server', _$server);
  static List<Message> _$messages(RCONState v) => v.messages;
  static const Field<RCONState, List<Message>> _f$messages = Field(
    'messages',
    _$messages,
  );
  static List<SavedMessage> _$savedMessages(RCONState v) => v.savedMessages;
  static const Field<RCONState, List<SavedMessage>> _f$savedMessages = Field(
    'savedMessages',
    _$savedMessages,
  );
  static Async<RCONConnection> _$connection(RCONState v) => v.connection;
  static const Field<RCONState, Async<RCONConnection>> _f$connection = Field(
    'connection',
    _$connection,
  );
  static DateTime? _$lastConnectionCheckTime(RCONState v) =>
      v.lastConnectionCheckTime;
  static const Field<RCONState, DateTime> _f$lastConnectionCheckTime = Field(
    'lastConnectionCheckTime',
    _$lastConnectionCheckTime,
    opt: true,
  );

  @override
  final MappableFields<RCONState> fields = const {
    #server: _f$server,
    #messages: _f$messages,
    #savedMessages: _f$savedMessages,
    #connection: _f$connection,
    #lastConnectionCheckTime: _f$lastConnectionCheckTime,
  };

  static RCONState _instantiate(DecodingData data) {
    return RCONState(
      server: data.dec(_f$server),
      messages: data.dec(_f$messages),
      savedMessages: data.dec(_f$savedMessages),
      connection: data.dec(_f$connection),
      lastConnectionCheckTime: data.dec(_f$lastConnectionCheckTime),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RCONState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RCONState>(map);
  }

  static RCONState fromJson(String json) {
    return ensureInitialized().decodeJson<RCONState>(json);
  }
}

mixin RCONStateMappable {
  String toJson() {
    return RCONStateMapper.ensureInitialized().encodeJson<RCONState>(
      this as RCONState,
    );
  }

  Map<String, dynamic> toMap() {
    return RCONStateMapper.ensureInitialized().encodeMap<RCONState>(
      this as RCONState,
    );
  }

  RCONStateCopyWith<RCONState, RCONState, RCONState> get copyWith =>
      _RCONStateCopyWithImpl<RCONState, RCONState>(
        this as RCONState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RCONStateMapper.ensureInitialized().stringifyValue(
      this as RCONState,
    );
  }

  @override
  bool operator ==(Object other) {
    return RCONStateMapper.ensureInitialized().equalsValue(
      this as RCONState,
      other,
    );
  }

  @override
  int get hashCode {
    return RCONStateMapper.ensureInitialized().hashValue(this as RCONState);
  }
}

extension RCONStateValueCopy<$R, $Out> on ObjectCopyWith<$R, RCONState, $Out> {
  RCONStateCopyWith<$R, RCONState, $Out> get $asRCONState =>
      $base.as((v, t, t2) => _RCONStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RCONStateCopyWith<$R, $In extends RCONState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ServerCopyWith<$R, Server, Server> get server;
  ListCopyWith<$R, Message, ObjectCopyWith<$R, Message, Message>> get messages;
  ListCopyWith<
    $R,
    SavedMessage,
    SavedMessageCopyWith<$R, SavedMessage, SavedMessage>
  >
  get savedMessages;
  $R call({
    Server? server,
    List<Message>? messages,
    List<SavedMessage>? savedMessages,
    Async<RCONConnection>? connection,
    DateTime? lastConnectionCheckTime,
  });
  RCONStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RCONStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RCONState, $Out>
    implements RCONStateCopyWith<$R, RCONState, $Out> {
  _RCONStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RCONState> $mapper =
      RCONStateMapper.ensureInitialized();
  @override
  ServerCopyWith<$R, Server, Server> get server =>
      $value.server.copyWith.$chain((v) => call(server: v));
  @override
  ListCopyWith<$R, Message, ObjectCopyWith<$R, Message, Message>>
  get messages => ListCopyWith(
    $value.messages,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(messages: v),
  );
  @override
  ListCopyWith<
    $R,
    SavedMessage,
    SavedMessageCopyWith<$R, SavedMessage, SavedMessage>
  >
  get savedMessages => ListCopyWith(
    $value.savedMessages,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(savedMessages: v),
  );
  @override
  $R call({
    Server? server,
    List<Message>? messages,
    List<SavedMessage>? savedMessages,
    Async<RCONConnection>? connection,
    Object? lastConnectionCheckTime = $none,
  }) => $apply(
    FieldCopyWithData({
      if (server != null) #server: server,
      if (messages != null) #messages: messages,
      if (savedMessages != null) #savedMessages: savedMessages,
      if (connection != null) #connection: connection,
      if (lastConnectionCheckTime != $none)
        #lastConnectionCheckTime: lastConnectionCheckTime,
    }),
  );
  @override
  RCONState $make(CopyWithData data) => RCONState(
    server: data.get(#server, or: $value.server),
    messages: data.get(#messages, or: $value.messages),
    savedMessages: data.get(#savedMessages, or: $value.savedMessages),
    connection: data.get(#connection, or: $value.connection),
    lastConnectionCheckTime: data.get(
      #lastConnectionCheckTime,
      or: $value.lastConnectionCheckTime,
    ),
  );

  @override
  RCONStateCopyWith<$R2, RCONState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RCONStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

