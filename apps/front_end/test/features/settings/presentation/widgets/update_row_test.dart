import 'package:arkie_core/features/settings/domain/check_for_update.dart';
import 'package:arkie_core/features/settings/domain/get_app_version_info.dart';
import 'package:arkie_core/testing/fake_releases_api.dart';
import 'package:arkie_state/features/settings/app_version_cubit.dart';
import 'package:cs2_rcon_front_end/features/settings/presentation/widgets/update_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('UpdateRow', () {
    AppVersionCubit buildCubit({
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

    Future<void> pumpRow(WidgetTester tester, AppVersionCubit cubit) async {
      await tester.pumpWidget(
        BlocProvider<AppVersionCubit>.value(
          value: cubit,
          child: const MaterialApp(home: Scaffold(body: UpdateRow())),
        ),
      );
    }

    testWidgets('says it is checking before the check comes back', (tester) async {
      final cubit = buildCubit(releasesApi: FakeReleasesApi());
      addTearDown(cubit.close);

      await pumpRow(tester, cubit);

      expect(find.text('Checking for a newer release…'), findsOneWidget);
    });

    testWidgets('says the app is up to date when nothing newer is released', (tester) async {
      final cubit = buildCubit(releasesApi: FakeReleasesApi(latestReleaseTag: const Ok('v0.0.41')));
      addTearDown(cubit.close);
      await pumpRow(tester, cubit);

      await cubit.checkForUpdate();
      await tester.pump();

      expect(find.text('Arkie is up to date'), findsOneWidget);
    });

    testWidgets('names the newer version and links out to it', (tester) async {
      final cubit = buildCubit(releasesApi: FakeReleasesApi(latestReleaseTag: const Ok('v0.0.42')));
      addTearDown(cubit.close);
      await pumpRow(tester, cubit);

      await cubit.checkForUpdate();
      await tester.pump();

      expect(find.text('Arkie 0.0.42 has been released'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
    });

    testWidgets('checks again when the failed row is tapped', (tester) async {
      final releasesApi = FakeReleasesApi(latestReleaseTag: Err(Exception('offline')));
      final cubit = buildCubit(releasesApi: releasesApi);
      addTearDown(cubit.close);
      await pumpRow(tester, cubit);
      await cubit.checkForUpdate();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(releasesApi.fetchLatestReleaseTagCallCount, 2);
      expect(find.text('Could not reach the releases to check for an update'), findsOneWidget);
    });
  });
}
