import 'package:arkie_core/features/settings/data/api/releases_api.dart';
import 'package:oxidized/oxidized.dart';

class FakeReleasesApi implements ReleasesApi {
  FakeReleasesApi({this.latestReleaseTag = const Ok('v1.0.0')});

  Result<String, Exception> latestReleaseTag;

  int fetchLatestReleaseTagCallCount = 0;

  @override
  Future<Result<String, Exception>> fetchLatestReleaseTag() async {
    fetchLatestReleaseTagCallCount += 1;
    return latestReleaseTag;
  }
}
