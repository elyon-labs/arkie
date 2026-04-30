import 'package:dart_mappable/dart_mappable.dart';

part 'server_status_json.mapper.dart';

@MappableClass()
class ServerStatusJson with ServerStatusJsonMappable {
  ServerStatusJson({
    required this.processUptime,
    required this.buildVersion,
    required this.buildSourceRevision,
    required this.memPhysTotalGb,
    required this.memPhysAvailGb,
    required this.server,
  });

  @MappableField(key: 'process_uptime')
  final int processUptime;
  @MappableField(key: 'build_version')
  final int buildVersion;
  @MappableField(key: 'build_source_revision')
  final String buildSourceRevision;
  @MappableField(key: 'mem_phys_total_gb')
  final double memPhysTotalGb;
  @MappableField(key: 'mem_phys_avail_gb')
  final double memPhysAvailGb;
  final ServerJson server;
}

@MappableClass()
class ServerJson with ServerJsonMappable {
  ServerJson({
    required this.isHibernating,
    required this.cpuUsage,
    required this.clientsBot,
    required this.clientsHuman,
    required this.clientsProxies,
    required this.clients,
    required this.map,
    required this.addon,
    required this.udpPort,
  });

  @MappableField(key: 'hibernating')
  final bool isHibernating;
  @MappableField(key: 'cpu_usage')
  final double cpuUsage;
  @MappableField(key: 'clients_bot')
  final int clientsBot;
  @MappableField(key: 'clients_human')
  final int clientsHuman;
  @MappableField(key: 'clients_proxies')
  final int clientsProxies;
  final List<ClientJson> clients;
  final String map;
  final String addon;
  @MappableField(key: 'udp_port')
  final int udpPort;
}

@MappableClass()
class ClientJson with ClientJsonMappable {
  ClientJson({
    required this.steamId64,
    required this.steamId,
    required this.isBot,
    required this.name,
  });

  @MappableField(key: 'steamid64')
  final String steamId64;
  @MappableField(key: 'steamid')
  final String steamId;
  @MappableField(key: 'bot')
  final bool isBot;
  final String name;
}
