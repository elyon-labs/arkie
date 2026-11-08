import 'package:arkie_core/features/settings/domain/check_for_update.dart';
import 'package:arkie_core/features/settings/domain/get_app_version_info.dart';
import 'package:arkie_core/features/settings/domain/models/update_status.dart';
import 'package:arkie_core/testing/fake_releases_api.dart';
import 'package:arkie_state/features/settings/app_version_cubit.dart';
import 'package:dart_foundation/dart_foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('AppVersionCubit', () {
    AppVersionCubit buildSubject({
      String installed = '0.0.41',
      required FakeReleasesApi releasesApi,
    }) {
      final getAppVersionInfo = GetAppVersionInfo(
        packageInfo: PackageInfo(
          appName: 'Arkie',
          packageName: 'com.elyonlabs.arkie',
          version: installed,
          buildNumber: '43',
        ),
      );

      return AppVersionCubit(
        getAppVersionInfo: getAppVersionInfo,
        checkForUpdate: CheckForUpdate(
          getAppVersionInfo: getAppVersionInfo,
          releasesApi: releasesApi,
        ),
      );
    }

    test('starts with the running version and no update check made', () {
      final subject = buildSubject(releasesApi: FakeReleasesApi());
      addTearDown(subject.close);

      expect('${subject.state.appVersion.unwrap().version}', '0.0.41');
      expect(subject.state.appVersion.unwrap().buildNumber, '43');
      expect(subject.state.updateStatus, const Idle<UpdateStatus>());
    });

    test('loads the update status when asked to check', () async {
      final subject = buildSubject(
        releasesApi: FakeReleasesApi(latestReleaseTag: const Ok('v0.0.42')),
      );
      addTearDown(subject.close);

      await subject.checkForUpdate();

      expect(subject.state.updateStatus.unwrap(), isA<UpdateAvailable>());
    });

    test('carries the failure when the check cannot be made', () async {
      final subject = buildSubject(
        releasesApi: FakeReleasesApi(latestReleaseTag: Err(Exception('offline'))),
      );
      addTearDown(subject.close);

      await subject.checkForUpdate();

      expect(subject.state.updateStatus.isError, isTrue);
    });

    test('leaves the version alone when the check fails', () async {
      final subject = buildSubject(
        releasesApi: FakeReleasesApi(latestReleaseTag: Err(Exception('offline'))),
      );
      addTearDown(subject.close);

      await subject.checkForUpdate();

      expect('${subject.state.appVersion.unwrap().version}', '0.0.41');
    });

    test('ignores a second check while one is still running', () async {
      final releasesApi = FakeReleasesApi();
      final subject = buildSubject(releasesApi: releasesApi);
      addTearDown(subject.close);

      await Future.wait([subject.checkForUpdate(), subject.checkForUpdate()]);

      expect(releasesApi.fetchLatestReleaseTagCallCount, 1);
    });
  });
}
