import 'package:dart_mappable/dart_mappable.dart';

part 'server_management_state.mapper.dart';

@MappableClass()
class ServerManagementState with ServerManagementStateMappable {
  const ServerManagementState({
    required this.isBusy,
    required this.isStreamingLogs,
    required this.status,
    required this.logs,
  });

  factory ServerManagementState.initial() {
    return const ServerManagementState(
      isBusy: false,
      isStreamingLogs: false,
      status: null,
      logs: [],
    );
  }

  final bool isBusy;
  final bool isStreamingLogs;
  final String? status;
  final List<String> logs;
}
