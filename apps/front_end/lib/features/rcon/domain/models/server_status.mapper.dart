// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'server_status.dart';

class ServerStatusMapper extends ClassMapperBase<ServerStatus> {
  ServerStatusMapper._();

  static ServerStatusMapper? _instance;
  static ServerStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServerStatusMapper._());
      PlayerInfoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ServerStatus';

  static String _$hostname(ServerStatus v) => v.hostname;
  static const Field<ServerStatus, String> _f$hostname = Field(
    'hostname',
    _$hostname,
  );
  static String _$version(ServerStatus v) => v.version;
  static const Field<ServerStatus, String> _f$version = Field(
    'version',
    _$version,
  );
  static InternetAddress _$address(ServerStatus v) => v.address;
  static const Field<ServerStatus, InternetAddress> _f$address = Field(
    'address',
    _$address,
  );
  static int _$port(ServerStatus v) => v.port;
  static const Field<ServerStatus, int> _f$port = Field('port', _$port);
  static String _$os(ServerStatus v) => v.os;
  static const Field<ServerStatus, String> _f$os = Field('os', _$os);
  static List<PlayerInfo> _$players(ServerStatus v) => v.players;
  static const Field<ServerStatus, List<PlayerInfo>> _f$players = Field(
    'players',
    _$players,
  );
  static int _$numPlayers(ServerStatus v) => v.numPlayers;
  static const Field<ServerStatus, int> _f$numPlayers = Field(
    'numPlayers',
    _$numPlayers,
  );
  static int _$numMaxPlayers(ServerStatus v) => v.numMaxPlayers;
  static const Field<ServerStatus, int> _f$numMaxPlayers = Field(
    'numMaxPlayers',
    _$numMaxPlayers,
  );
  static int _$numHumans(ServerStatus v) => v.numHumans;
  static const Field<ServerStatus, int> _f$numHumans = Field(
    'numHumans',
    _$numHumans,
  );
  static int _$numBots(ServerStatus v) => v.numBots;
  static const Field<ServerStatus, int> _f$numBots = Field(
    'numBots',
    _$numBots,
  );
  static String _$map(ServerStatus v) => v.map;
  static const Field<ServerStatus, String> _f$map = Field('map', _$map);
  static String _$addressWithPort(ServerStatus v) => v.addressWithPort;
  static const Field<ServerStatus, String> _f$addressWithPort = Field(
    'addressWithPort',
    _$addressWithPort,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<ServerStatus> fields = const {
    #hostname: _f$hostname,
    #version: _f$version,
    #address: _f$address,
    #port: _f$port,
    #os: _f$os,
    #players: _f$players,
    #numPlayers: _f$numPlayers,
    #numMaxPlayers: _f$numMaxPlayers,
    #numHumans: _f$numHumans,
    #numBots: _f$numBots,
    #map: _f$map,
    #addressWithPort: _f$addressWithPort,
  };

  static ServerStatus _instantiate(DecodingData data) {
    return ServerStatus(
      hostname: data.dec(_f$hostname),
      version: data.dec(_f$version),
      address: data.dec(_f$address),
      port: data.dec(_f$port),
      os: data.dec(_f$os),
      players: data.dec(_f$players),
      numPlayers: data.dec(_f$numPlayers),
      numMaxPlayers: data.dec(_f$numMaxPlayers),
      numHumans: data.dec(_f$numHumans),
      numBots: data.dec(_f$numBots),
      map: data.dec(_f$map),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServerStatus fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServerStatus>(map);
  }

  static ServerStatus fromJson(String json) {
    return ensureInitialized().decodeJson<ServerStatus>(json);
  }
}

mixin ServerStatusMappable {
  String toJson() {
    return ServerStatusMapper.ensureInitialized().encodeJson<ServerStatus>(
      this as ServerStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return ServerStatusMapper.ensureInitialized().encodeMap<ServerStatus>(
      this as ServerStatus,
    );
  }

  ServerStatusCopyWith<ServerStatus, ServerStatus, ServerStatus> get copyWith =>
      _ServerStatusCopyWithImpl<ServerStatus, ServerStatus>(
        this as ServerStatus,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ServerStatusMapper.ensureInitialized().stringifyValue(
      this as ServerStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServerStatusMapper.ensureInitialized().equalsValue(
      this as ServerStatus,
      other,
    );
  }

  @override
  int get hashCode {
    return ServerStatusMapper.ensureInitialized().hashValue(
      this as ServerStatus,
    );
  }
}

extension ServerStatusValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServerStatus, $Out> {
  ServerStatusCopyWith<$R, ServerStatus, $Out> get $asServerStatus =>
      $base.as((v, t, t2) => _ServerStatusCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServerStatusCopyWith<$R, $In extends ServerStatus, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, PlayerInfo, PlayerInfoCopyWith<$R, PlayerInfo, PlayerInfo>>
  get players;
  $R call({
    String? hostname,
    String? version,
    InternetAddress? address,
    int? port,
    String? os,
    List<PlayerInfo>? players,
    int? numPlayers,
    int? numMaxPlayers,
    int? numHumans,
    int? numBots,
    String? map,
  });
  ServerStatusCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ServerStatusCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServerStatus, $Out>
    implements ServerStatusCopyWith<$R, ServerStatus, $Out> {
  _ServerStatusCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServerStatus> $mapper =
      ServerStatusMapper.ensureInitialized();
  @override
  ListCopyWith<$R, PlayerInfo, PlayerInfoCopyWith<$R, PlayerInfo, PlayerInfo>>
  get players => ListCopyWith(
    $value.players,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(players: v),
  );
  @override
  $R call({
    String? hostname,
    String? version,
    InternetAddress? address,
    int? port,
    String? os,
    List<PlayerInfo>? players,
    int? numPlayers,
    int? numMaxPlayers,
    int? numHumans,
    int? numBots,
    String? map,
  }) => $apply(
    FieldCopyWithData({
      if (hostname != null) #hostname: hostname,
      if (version != null) #version: version,
      if (address != null) #address: address,
      if (port != null) #port: port,
      if (os != null) #os: os,
      if (players != null) #players: players,
      if (numPlayers != null) #numPlayers: numPlayers,
      if (numMaxPlayers != null) #numMaxPlayers: numMaxPlayers,
      if (numHumans != null) #numHumans: numHumans,
      if (numBots != null) #numBots: numBots,
      if (map != null) #map: map,
    }),
  );
  @override
  ServerStatus $make(CopyWithData data) => ServerStatus(
    hostname: data.get(#hostname, or: $value.hostname),
    version: data.get(#version, or: $value.version),
    address: data.get(#address, or: $value.address),
    port: data.get(#port, or: $value.port),
    os: data.get(#os, or: $value.os),
    players: data.get(#players, or: $value.players),
    numPlayers: data.get(#numPlayers, or: $value.numPlayers),
    numMaxPlayers: data.get(#numMaxPlayers, or: $value.numMaxPlayers),
    numHumans: data.get(#numHumans, or: $value.numHumans),
    numBots: data.get(#numBots, or: $value.numBots),
    map: data.get(#map, or: $value.map),
  );

  @override
  ServerStatusCopyWith<$R2, ServerStatus, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServerStatusCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

