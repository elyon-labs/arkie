import 'package:arkie_core/features/settings/domain/check_for_update.dart';
import 'package:arkie_core/features/settings/domain/get_app_version_info.dart';
import 'package:arkie_core/features/settings/domain/models/update_status.dart';
import 'package:arkie_core/testing/fake_releases_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

void main() {
  CheckForUpdate buildSubject({required String installed, required FakeReleasesApi releasesApi}) {
    return CheckForUpdate(
      getAppVersionInfo: GetAppVersionInfo(
        packageInfo: PackageInfo(
          appName: 'Arkie',
          packageName: 'com.elyonlabs.arkie',
          version: installed,
          buildNumber: '43',
        ),
      ),
      releasesApi: releasesApi,
    );
  }

  test('reports the newer version when one has been released', () async {
    final subject = buildSubject(
      installed: '0.0.41',
      releasesApi: FakeReleasesApi(latestReleaseTag: const Ok('v0.0.42')),
    );

    final result = await subject();

    expect(result.unwrap(), UpdateAvailable(version: Version.parse('0.0.42')));
  });

  test('reports up to date when the running version is the latest one', () async {
    final subject = buildSubject(
      installed: '0.0.42',
      releasesApi: FakeReleasesApi(latestReleaseTag: const Ok('v0.0.42')),
    );

    final result = await subject();

    expect(result.unwrap(), const UpToDate());
  });

  test('reports up to date when the running version is ahead of the latest release', () async {
    final subject = buildSubject(
      installed: '0.1.0',
      releasesApi: FakeReleasesApi(latestReleaseTag: const Ok('v0.0.42')),
    );

    final result = await subject();

    expect(result.unwrap(), const UpToDate());
  });

  test('reads a tag that was published without its leading v', () async {
    final subject = buildSubject(
      installed: '0.0.41',
      releasesApi: FakeReleasesApi(latestReleaseTag: const Ok('0.0.42')),
    );

    final result = await subject();

    expect(result.unwrap(), UpdateAvailable(version: Version.parse('0.0.42')));
  });

  test('fails when the latest release cannot be fetched', () async {
    final fetchError = Exception('offline');
    final subject = buildSubject(
      installed: '0.0.41',
      releasesApi: FakeReleasesApi(latestReleaseTag: Err(fetchError)),
    );

    final result = await subject();

    expect(result.unwrapErr(), same(fetchError));
  });

  test('fails without asking GitHub when the running version is unreadable', () async {
    final releasesApi = FakeReleasesApi();
    final subject = buildSubject(installed: 'nightly', releasesApi: releasesApi);

    final result = await subject();

    expect(result.isErr(), isTrue);
    expect(releasesApi.fetchLatestReleaseTagCallCount, 0);
  });

  test('fails when the latest release is not tagged as a version', () async {
    final subject = buildSubject(
      installed: '0.0.41',
      releasesApi: FakeReleasesApi(latestReleaseTag: const Ok('nightly')),
    );

    final result = await subject();

    expect(result.isErr(), isTrue);
  });
}
