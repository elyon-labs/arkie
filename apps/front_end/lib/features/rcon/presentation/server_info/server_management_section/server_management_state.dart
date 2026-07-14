import 'package:dart_mappable/dart_mappable.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/private_key_health.dart';

part 'server_management_state.mapper.dart';

@MappableClass()
class ServerManagementState with ServerManagementStateMappable {
  const ServerManagementState({
    required this.isBusy,
    required this.isStreamingLogs,
    required this.status,
    required this.logs,
    required this.keyHealthStatus,
    this.keyReplacementReason,
  });

  factory ServerManagementState.initial() {
    return const ServerManagementState(
      isBusy: false,
      isStreamingLogs: false,
      status: null,
      logs: [],
      keyHealthStatus: PrivateKeyHealthStatus.checking,
    );
  }

  final bool isBusy;
  final bool isStreamingLogs;
  final String? status;
  final List<String> logs;
  final PrivateKeyHealthStatus keyHealthStatus;
  final PrivateKeyReplacementReason? keyReplacementReason;
}
