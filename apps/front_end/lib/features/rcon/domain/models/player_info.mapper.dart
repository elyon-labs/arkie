// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'player_info.dart';

class PlayerInfoMapper extends ClassMapperBase<PlayerInfo> {
  PlayerInfoMapper._();

  static PlayerInfoMapper? _instance;
  static PlayerInfoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlayerInfoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PlayerInfo';

  static bool _$isBot(PlayerInfo v) => v.isBot;
  static const Field<PlayerInfo, bool> _f$isBot = Field('isBot', _$isBot);
  static String _$name(PlayerInfo v) => v.name;
  static const Field<PlayerInfo, String> _f$name = Field('name', _$name);
  static int _$id(PlayerInfo v) => v.id;
  static const Field<PlayerInfo, int> _f$id = Field('id', _$id);
  static int _$ping(PlayerInfo v) => v.ping;
  static const Field<PlayerInfo, int> _f$ping = Field('ping', _$ping);
  static String _$state(PlayerInfo v) => v.state;
  static const Field<PlayerInfo, String> _f$state = Field('state', _$state);
  static String? _$steamId(PlayerInfo v) => v.steamId;
  static const Field<PlayerInfo, String> _f$steamId = Field(
    'steamId',
    _$steamId,
  );
  static String? _$steamId64(PlayerInfo v) => v.steamId64;
  static const Field<PlayerInfo, String> _f$steamId64 = Field(
    'steamId64',
    _$steamId64,
  );

  @override
  final MappableFields<PlayerInfo> fields = const {
    #isBot: _f$isBot,
    #name: _f$name,
    #id: _f$id,
    #ping: _f$ping,
    #state: _f$state,
    #steamId: _f$steamId,
    #steamId64: _f$steamId64,
  };

  static PlayerInfo _instantiate(DecodingData data) {
    return PlayerInfo(
      isBot: data.dec(_f$isBot),
      name: data.dec(_f$name),
      id: data.dec(_f$id),
      ping: data.dec(_f$ping),
      state: data.dec(_f$state),
      steamId: data.dec(_f$steamId),
      steamId64: data.dec(_f$steamId64),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PlayerInfo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlayerInfo>(map);
  }

  static PlayerInfo fromJson(String json) {
    return ensureInitialized().decodeJson<PlayerInfo>(json);
  }
}

mixin PlayerInfoMappable {
  String toJson() {
    return PlayerInfoMapper.ensureInitialized().encodeJson<PlayerInfo>(
      this as PlayerInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return PlayerInfoMapper.ensureInitialized().encodeMap<PlayerInfo>(
      this as PlayerInfo,
    );
  }

  PlayerInfoCopyWith<PlayerInfo, PlayerInfo, PlayerInfo> get copyWith =>
      _PlayerInfoCopyWithImpl<PlayerInfo, PlayerInfo>(
        this as PlayerInfo,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PlayerInfoMapper.ensureInitialized().stringifyValue(
      this as PlayerInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    return PlayerInfoMapper.ensureInitialized().equalsValue(
      this as PlayerInfo,
      other,
    );
  }

  @override
  int get hashCode {
    return PlayerInfoMapper.ensureInitialized().hashValue(this as PlayerInfo);
  }
}

extension PlayerInfoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlayerInfo, $Out> {
  PlayerInfoCopyWith<$R, PlayerInfo, $Out> get $asPlayerInfo =>
      $base.as((v, t, t2) => _PlayerInfoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PlayerInfoCopyWith<$R, $In extends PlayerInfo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    bool? isBot,
    String? name,
    int? id,
    int? ping,
    String? state,
    String? steamId,
    String? steamId64,
  });
  PlayerInfoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PlayerInfoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlayerInfo, $Out>
    implements PlayerInfoCopyWith<$R, PlayerInfo, $Out> {
  _PlayerInfoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlayerInfo> $mapper =
      PlayerInfoMapper.ensureInitialized();
  @override
  $R call({
    bool? isBot,
    String? name,
    int? id,
    int? ping,
    String? state,
    Object? steamId = $none,
    Object? steamId64 = $none,
  }) => $apply(
    FieldCopyWithData({
      if (isBot != null) #isBot: isBot,
      if (name != null) #name: name,
      if (id != null) #id: id,
      if (ping != null) #ping: ping,
      if (state != null) #state: state,
      if (steamId != $none) #steamId: steamId,
      if (steamId64 != $none) #steamId64: steamId64,
    }),
  );
  @override
  PlayerInfo $make(CopyWithData data) => PlayerInfo(
    isBot: data.get(#isBot, or: $value.isBot),
    name: data.get(#name, or: $value.name),
    id: data.get(#id, or: $value.id),
    ping: data.get(#ping, or: $value.ping),
    state: data.get(#state, or: $value.state),
    steamId: data.get(#steamId, or: $value.steamId),
    steamId64: data.get(#steamId64, or: $value.steamId64),
  );

  @override
  PlayerInfoCopyWith<$R2, PlayerInfo, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PlayerInfoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

