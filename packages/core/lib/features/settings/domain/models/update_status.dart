import 'package:dart_mappable/dart_mappable.dart';
import 'package:version/version.dart';

part 'update_status.mapper.dart';

/// How the running build compares to the newest one Arkie has published.
@MappableClass(discriminatorKey: 'status')
sealed class UpdateStatus with UpdateStatusMappable {
  const UpdateStatus();
}

@MappableClass()
class UpToDate extends UpdateStatus with UpToDateMappable {
  const UpToDate();
}

@MappableClass()
class UpdateAvailable extends UpdateStatus with UpdateAvailableMappable {
  const UpdateAvailable({required this.version});

  /// The newest published version, which is ahead of the one running.
  final Version version;
}
