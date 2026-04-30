import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:oxidized/oxidized.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

typedef VersionInfo = ({Version version, String buildNumber});

class GetAppVersionInfo {
  GetAppVersionInfo({required PackageInfo packageInfo}) : _packageInfo = packageInfo;

  factory GetAppVersionInfo.create() {
    return GetAppVersionInfo(packageInfo: inject());
  }

  final PackageInfo _packageInfo;

  Result<VersionInfo, Exception> call() {
    try {
      final version = Version.parse(_packageInfo.version);
      return Ok((version: version, buildNumber: _packageInfo.buildNumber));
    } catch (e) {
      return Err(Exception('Failed to parse app version: ${_packageInfo.version}'));
    }
  }
}
