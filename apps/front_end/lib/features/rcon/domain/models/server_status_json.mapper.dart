// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'server_status_json.dart';

class ServerStatusJsonMapper extends ClassMapperBase<ServerStatusJson> {
  ServerStatusJsonMapper._();

  static ServerStatusJsonMapper? _instance;
  static ServerStatusJsonMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServerStatusJsonMapper._());
      ServerJsonMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ServerStatusJson';

  static int _$processUptime(ServerStatusJson v) => v.processUptime;
  static const Field<ServerStatusJson, int> _f$processUptime = Field(
    'processUptime',
    _$processUptime,
    key: r'process_uptime',
  );
  static int _$buildVersion(ServerStatusJson v) => v.buildVersion;
  static const Field<ServerStatusJson, int> _f$buildVersion = Field(
    'buildVersion',
    _$buildVersion,
    key: r'build_version',
  );
  static String _$buildSourceRevision(ServerStatusJson v) =>
      v.buildSourceRevision;
  static const Field<ServerStatusJson, String> _f$buildSourceRevision = Field(
    'buildSourceRevision',
    _$buildSourceRevision,
    key: r'build_source_revision',
  );
  static double _$memPhysTotalGb(ServerStatusJson v) => v.memPhysTotalGb;
  static const Field<ServerStatusJson, double> _f$memPhysTotalGb = Field(
    'memPhysTotalGb',
    _$memPhysTotalGb,
    key: r'mem_phys_total_gb',
  );
  static double _$memPhysAvailGb(ServerStatusJson v) => v.memPhysAvailGb;
  static const Field<ServerStatusJson, double> _f$memPhysAvailGb = Field(
    'memPhysAvailGb',
    _$memPhysAvailGb,
    key: r'mem_phys_avail_gb',
  );
  static ServerJson _$server(ServerStatusJson v) => v.server;
  static const Field<ServerStatusJson, ServerJson> _f$server = Field(
    'server',
    _$server,
  );

  @override
  final MappableFields<ServerStatusJson> fields = const {
    #processUptime: _f$processUptime,
    #buildVersion: _f$buildVersion,
    #buildSourceRevision: _f$buildSourceRevision,
    #memPhysTotalGb: _f$memPhysTotalGb,
    #memPhysAvailGb: _f$memPhysAvailGb,
    #server: _f$server,
  };

  static ServerStatusJson _instantiate(DecodingData data) {
    return ServerStatusJson(
      processUptime: data.dec(_f$processUptime),
      buildVersion: data.dec(_f$buildVersion),
      buildSourceRevision: data.dec(_f$buildSourceRevision),
      memPhysTotalGb: data.dec(_f$memPhysTotalGb),
      memPhysAvailGb: data.dec(_f$memPhysAvailGb),
      server: data.dec(_f$server),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServerStatusJson fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServerStatusJson>(map);
  }

  static ServerStatusJson fromJson(String json) {
    return ensureInitialized().decodeJson<ServerStatusJson>(json);
  }
}

mixin ServerStatusJsonMappable {
  String toJson() {
    return ServerStatusJsonMapper.ensureInitialized()
        .encodeJson<ServerStatusJson>(this as ServerStatusJson);
  }

  Map<String, dynamic> toMap() {
    return ServerStatusJsonMapper.ensureInitialized()
        .encodeMap<ServerStatusJson>(this as ServerStatusJson);
  }

  ServerStatusJsonCopyWith<ServerStatusJson, ServerStatusJson, ServerStatusJson>
  get copyWith =>
      _ServerStatusJsonCopyWithImpl<ServerStatusJson, ServerStatusJson>(
        this as ServerStatusJson,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ServerStatusJsonMapper.ensureInitialized().stringifyValue(
      this as ServerStatusJson,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServerStatusJsonMapper.ensureInitialized().equalsValue(
      this as ServerStatusJson,
      other,
    );
  }

  @override
  int get hashCode {
    return ServerStatusJsonMapper.ensureInitialized().hashValue(
      this as ServerStatusJson,
    );
  }
}

extension ServerStatusJsonValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServerStatusJson, $Out> {
  ServerStatusJsonCopyWith<$R, ServerStatusJson, $Out>
  get $asServerStatusJson =>
      $base.as((v, t, t2) => _ServerStatusJsonCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServerStatusJsonCopyWith<$R, $In extends ServerStatusJson, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ServerJsonCopyWith<$R, ServerJson, ServerJson> get server;
  $R call({
    int? processUptime,
    int? buildVersion,
    String? buildSourceRevision,
    double? memPhysTotalGb,
    double? memPhysAvailGb,
    ServerJson? server,
  });
  ServerStatusJsonCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ServerStatusJsonCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServerStatusJson, $Out>
    implements ServerStatusJsonCopyWith<$R, ServerStatusJson, $Out> {
  _ServerStatusJsonCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServerStatusJson> $mapper =
      ServerStatusJsonMapper.ensureInitialized();
  @override
  ServerJsonCopyWith<$R, ServerJson, ServerJson> get server =>
      $value.server.copyWith.$chain((v) => call(server: v));
  @override
  $R call({
    int? processUptime,
    int? buildVersion,
    String? buildSourceRevision,
    double? memPhysTotalGb,
    double? memPhysAvailGb,
    ServerJson? server,
  }) => $apply(
    FieldCopyWithData({
      if (processUptime != null) #processUptime: processUptime,
      if (buildVersion != null) #buildVersion: buildVersion,
      if (buildSourceRevision != null)
        #buildSourceRevision: buildSourceRevision,
      if (memPhysTotalGb != null) #memPhysTotalGb: memPhysTotalGb,
      if (memPhysAvailGb != null) #memPhysAvailGb: memPhysAvailGb,
      if (server != null) #server: server,
    }),
  );
  @override
  ServerStatusJson $make(CopyWithData data) => ServerStatusJson(
    processUptime: data.get(#processUptime, or: $value.processUptime),
    buildVersion: data.get(#buildVersion, or: $value.buildVersion),
    buildSourceRevision: data.get(
      #buildSourceRevision,
      or: $value.buildSourceRevision,
    ),
    memPhysTotalGb: data.get(#memPhysTotalGb, or: $value.memPhysTotalGb),
    memPhysAvailGb: data.get(#memPhysAvailGb, or: $value.memPhysAvailGb),
    server: data.get(#server, or: $value.server),
  );

  @override
  ServerStatusJsonCopyWith<$R2, ServerStatusJson, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServerStatusJsonCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ServerJsonMapper extends ClassMapperBase<ServerJson> {
  ServerJsonMapper._();

  static ServerJsonMapper? _instance;
  static ServerJsonMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServerJsonMapper._());
      ClientJsonMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ServerJson';

  static bool _$isHibernating(ServerJson v) => v.isHibernating;
  static const Field<ServerJson, bool> _f$isHibernating = Field(
    'isHibernating',
    _$isHibernating,
    key: r'hibernating',
  );
  static double _$cpuUsage(ServerJson v) => v.cpuUsage;
  static const Field<ServerJson, double> _f$cpuUsage = Field(
    'cpuUsage',
    _$cpuUsage,
    key: r'cpu_usage',
  );
  static int _$clientsBot(ServerJson v) => v.clientsBot;
  static const Field<ServerJson, int> _f$clientsBot = Field(
    'clientsBot',
    _$clientsBot,
    key: r'clients_bot',
  );
  static int _$clientsHuman(ServerJson v) => v.clientsHuman;
  static const Field<ServerJson, int> _f$clientsHuman = Field(
    'clientsHuman',
    _$clientsHuman,
    key: r'clients_human',
  );
  static int _$clientsProxies(ServerJson v) => v.clientsProxies;
  static const Field<ServerJson, int> _f$clientsProxies = Field(
    'clientsProxies',
    _$clientsProxies,
    key: r'clients_proxies',
  );
  static List<ClientJson> _$clients(ServerJson v) => v.clients;
  static const Field<ServerJson, List<ClientJson>> _f$clients = Field(
    'clients',
    _$clients,
  );
  static String _$map(ServerJson v) => v.map;
  static const Field<ServerJson, String> _f$map = Field('map', _$map);
  static String _$addon(ServerJson v) => v.addon;
  static const Field<ServerJson, String> _f$addon = Field('addon', _$addon);
  static int _$udpPort(ServerJson v) => v.udpPort;
  static const Field<ServerJson, int> _f$udpPort = Field(
    'udpPort',
    _$udpPort,
    key: r'udp_port',
  );

  @override
  final MappableFields<ServerJson> fields = const {
    #isHibernating: _f$isHibernating,
    #cpuUsage: _f$cpuUsage,
    #clientsBot: _f$clientsBot,
    #clientsHuman: _f$clientsHuman,
    #clientsProxies: _f$clientsProxies,
    #clients: _f$clients,
    #map: _f$map,
    #addon: _f$addon,
    #udpPort: _f$udpPort,
  };

  static ServerJson _instantiate(DecodingData data) {
    return ServerJson(
      isHibernating: data.dec(_f$isHibernating),
      cpuUsage: data.dec(_f$cpuUsage),
      clientsBot: data.dec(_f$clientsBot),
      clientsHuman: data.dec(_f$clientsHuman),
      clientsProxies: data.dec(_f$clientsProxies),
      clients: data.dec(_f$clients),
      map: data.dec(_f$map),
      addon: data.dec(_f$addon),
      udpPort: data.dec(_f$udpPort),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServerJson fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServerJson>(map);
  }

  static ServerJson fromJson(String json) {
    return ensureInitialized().decodeJson<ServerJson>(json);
  }
}

mixin ServerJsonMappable {
  String toJson() {
    return ServerJsonMapper.ensureInitialized().encodeJson<ServerJson>(
      this as ServerJson,
    );
  }

  Map<String, dynamic> toMap() {
    return ServerJsonMapper.ensureInitialized().encodeMap<ServerJson>(
      this as ServerJson,
    );
  }

  ServerJsonCopyWith<ServerJson, ServerJson, ServerJson> get copyWith =>
      _ServerJsonCopyWithImpl<ServerJson, ServerJson>(
        this as ServerJson,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ServerJsonMapper.ensureInitialized().stringifyValue(
      this as ServerJson,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServerJsonMapper.ensureInitialized().equalsValue(
      this as ServerJson,
      other,
    );
  }

  @override
  int get hashCode {
    return ServerJsonMapper.ensureInitialized().hashValue(this as ServerJson);
  }
}

extension ServerJsonValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServerJson, $Out> {
  ServerJsonCopyWith<$R, ServerJson, $Out> get $asServerJson =>
      $base.as((v, t, t2) => _ServerJsonCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServerJsonCopyWith<$R, $In extends ServerJson, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, ClientJson, ClientJsonCopyWith<$R, ClientJson, ClientJson>>
  get clients;
  $R call({
    bool? isHibernating,
    double? cpuUsage,
    int? clientsBot,
    int? clientsHuman,
    int? clientsProxies,
    List<ClientJson>? clients,
    String? map,
    String? addon,
    int? udpPort,
  });
  ServerJsonCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ServerJsonCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServerJson, $Out>
    implements ServerJsonCopyWith<$R, ServerJson, $Out> {
  _ServerJsonCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServerJson> $mapper =
      ServerJsonMapper.ensureInitialized();
  @override
  ListCopyWith<$R, ClientJson, ClientJsonCopyWith<$R, ClientJson, ClientJson>>
  get clients => ListCopyWith(
    $value.clients,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(clients: v),
  );
  @override
  $R call({
    bool? isHibernating,
    double? cpuUsage,
    int? clientsBot,
    int? clientsHuman,
    int? clientsProxies,
    List<ClientJson>? clients,
    String? map,
    String? addon,
    int? udpPort,
  }) => $apply(
    FieldCopyWithData({
      if (isHibernating != null) #isHibernating: isHibernating,
      if (cpuUsage != null) #cpuUsage: cpuUsage,
      if (clientsBot != null) #clientsBot: clientsBot,
      if (clientsHuman != null) #clientsHuman: clientsHuman,
      if (clientsProxies != null) #clientsProxies: clientsProxies,
      if (clients != null) #clients: clients,
      if (map != null) #map: map,
      if (addon != null) #addon: addon,
      if (udpPort != null) #udpPort: udpPort,
    }),
  );
  @override
  ServerJson $make(CopyWithData data) => ServerJson(
    isHibernating: data.get(#isHibernating, or: $value.isHibernating),
    cpuUsage: data.get(#cpuUsage, or: $value.cpuUsage),
    clientsBot: data.get(#clientsBot, or: $value.clientsBot),
    clientsHuman: data.get(#clientsHuman, or: $value.clientsHuman),
    clientsProxies: data.get(#clientsProxies, or: $value.clientsProxies),
    clients: data.get(#clients, or: $value.clients),
    map: data.get(#map, or: $value.map),
    addon: data.get(#addon, or: $value.addon),
    udpPort: data.get(#udpPort, or: $value.udpPort),
  );

  @override
  ServerJsonCopyWith<$R2, ServerJson, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServerJsonCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ClientJsonMapper extends ClassMapperBase<ClientJson> {
  ClientJsonMapper._();

  static ClientJsonMapper? _instance;
  static ClientJsonMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ClientJsonMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ClientJson';

  static String _$steamId64(ClientJson v) => v.steamId64;
  static const Field<ClientJson, String> _f$steamId64 = Field(
    'steamId64',
    _$steamId64,
    key: r'steamid64',
  );
  static String _$steamId(ClientJson v) => v.steamId;
  static const Field<ClientJson, String> _f$steamId = Field(
    'steamId',
    _$steamId,
    key: r'steamid',
  );
  static bool _$isBot(ClientJson v) => v.isBot;
  static const Field<ClientJson, bool> _f$isBot = Field(
    'isBot',
    _$isBot,
    key: r'bot',
  );
  static String _$name(ClientJson v) => v.name;
  static const Field<ClientJson, String> _f$name = Field('name', _$name);

  @override
  final MappableFields<ClientJson> fields = const {
    #steamId64: _f$steamId64,
    #steamId: _f$steamId,
    #isBot: _f$isBot,
    #name: _f$name,
  };

  static ClientJson _instantiate(DecodingData data) {
    return ClientJson(
      steamId64: data.dec(_f$steamId64),
      steamId: data.dec(_f$steamId),
      isBot: data.dec(_f$isBot),
      name: data.dec(_f$name),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ClientJson fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ClientJson>(map);
  }

  static ClientJson fromJson(String json) {
    return ensureInitialized().decodeJson<ClientJson>(json);
  }
}

mixin ClientJsonMappable {
  String toJson() {
    return ClientJsonMapper.ensureInitialized().encodeJson<ClientJson>(
      this as ClientJson,
    );
  }

  Map<String, dynamic> toMap() {
    return ClientJsonMapper.ensureInitialized().encodeMap<ClientJson>(
      this as ClientJson,
    );
  }

  ClientJsonCopyWith<ClientJson, ClientJson, ClientJson> get copyWith =>
      _ClientJsonCopyWithImpl<ClientJson, ClientJson>(
        this as ClientJson,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ClientJsonMapper.ensureInitialized().stringifyValue(
      this as ClientJson,
    );
  }

  @override
  bool operator ==(Object other) {
    return ClientJsonMapper.ensureInitialized().equalsValue(
      this as ClientJson,
      other,
    );
  }

  @override
  int get hashCode {
    return ClientJsonMapper.ensureInitialized().hashValue(this as ClientJson);
  }
}

extension ClientJsonValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ClientJson, $Out> {
  ClientJsonCopyWith<$R, ClientJson, $Out> get $asClientJson =>
      $base.as((v, t, t2) => _ClientJsonCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ClientJsonCopyWith<$R, $In extends ClientJson, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? steamId64, String? steamId, bool? isBot, String? name});
  ClientJsonCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ClientJsonCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ClientJson, $Out>
    implements ClientJsonCopyWith<$R, ClientJson, $Out> {
  _ClientJsonCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ClientJson> $mapper =
      ClientJsonMapper.ensureInitialized();
  @override
  $R call({String? steamId64, String? steamId, bool? isBot, String? name}) =>
      $apply(
        FieldCopyWithData({
          if (steamId64 != null) #steamId64: steamId64,
          if (steamId != null) #steamId: steamId,
          if (isBot != null) #isBot: isBot,
          if (name != null) #name: name,
        }),
      );
  @override
  ClientJson $make(CopyWithData data) => ClientJson(
    steamId64: data.get(#steamId64, or: $value.steamId64),
    steamId: data.get(#steamId, or: $value.steamId),
    isBot: data.get(#isBot, or: $value.isBot),
    name: data.get(#name, or: $value.name),
  );

  @override
  ClientJsonCopyWith<$R2, ClientJson, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ClientJsonCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

