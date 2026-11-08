import 'package:arkie_core/features/settings/data/api/releases_api.dart';
import 'package:arkie_core/features/settings/domain/get_app_version_info.dart';
import 'package:arkie_core/features/settings/domain/models/update_status.dart';
import 'package:oxidized/oxidized.dart';
import 'package:version/version.dart';

/// Compares the running build against the newest published release.
///
/// Releases are the same ones the website lists, so what this reports and what
/// the release notes say are never out of step. A store still has to approve a
/// mobile build after its release is published, which can leave this reporting
/// an update a little before the store offers one.
class CheckForUpdate {
  CheckForUpdate({required GetAppVersionInfo getAppVersionInfo, required ReleasesApi releasesApi})
    : _getAppVersionInfo = getAppVersionInfo,
      _releasesApi = releasesApi;

  factory CheckForUpdate.create() {
    return CheckForUpdate(
      getAppVersionInfo: GetAppVersionInfo.create(),
      releasesApi: ReleasesApi.create(),
    );
  }

  final GetAppVersionInfo _getAppVersionInfo;
  final ReleasesApi _releasesApi;

  Future<Result<UpdateStatus, Exception>> call() async {
    return switch (_getAppVersionInfo()) {
      Err<VersionInfo, Exception>(:final error) => Err(error),
      Ok<VersionInfo, Exception>(:final value) => await _compareToLatest(value.version),
    };
  }

  Future<Result<UpdateStatus, Exception>> _compareToLatest(Version installed) async {
    return switch (await _releasesApi.fetchLatestReleaseTag()) {
      Err<String, Exception>(:final error) => Err(error),
      Ok<String, Exception>(:final value) => Result.of(() {
        final latest = _parseTag(value);
        return latest > installed ? UpdateAvailable(version: latest) : const UpToDate();
      }),
    };
  }

  Version _parseTag(String tag) {
    try {
      return Version.parse(tag.startsWith('v') ? tag.substring(1) : tag);
    } catch (e) {
      throw Exception('Failed to parse release tag: $tag');
    }
  }
}
