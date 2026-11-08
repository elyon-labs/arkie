import 'package:arkie_core/features/settings/domain/check_for_update.dart';
import 'package:arkie_core/features/settings/domain/get_app_version_info.dart';
import 'package:arkie_core/testing/fake_releases_api.dart';
import 'package:arkie_mobile/app.dart';
import 'package:arkie_mobile/features/settings/presentation/widgets/version_panel.dart';
import 'package:arkie_state/features/settings/app_version_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  AppVersionCubit buildCubit({String installed = '0.0.41', required FakeReleasesApi releasesApi}) {
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

  Future<void> pumpPanel(WidgetTester tester, AppVersionCubit cubit) async {
    await tester.pumpWidget(
      MobileApp(
        home: Scaffold(
          body: BlocProvider.value(value: cubit, child: const VersionPanel()),
        ),
      ),
    );
  }

  testWidgets('shows the running version and build', (tester) async {
    final cubit = buildCubit(releasesApi: FakeReleasesApi());
    addTearDown(cubit.close);

    await pumpPanel(tester, cubit);

    expect(find.text('0.0.41'), findsOneWidget);
    expect(find.text('43'), findsOneWidget);
  });

  testWidgets('says the app is up to date when nothing newer is released', (tester) async {
    final cubit = buildCubit(releasesApi: FakeReleasesApi(latestReleaseTag: const Ok('v0.0.41')));
    addTearDown(cubit.close);
    await pumpPanel(tester, cubit);

    await cubit.checkForUpdate();
    await tester.pump();

    expect(find.text('latest'), findsOneWidget);
    expect(find.text('Arkie is up to date.'), findsOneWidget);
  });

  testWidgets('names the newer version and offers its release notes', (tester) async {
    final cubit = buildCubit(releasesApi: FakeReleasesApi(latestReleaseTag: const Ok('v0.0.42')));
    addTearDown(cubit.close);
    await pumpPanel(tester, cubit);

    await cubit.checkForUpdate();
    await tester.pump();

    expect(find.text('update'), findsOneWidget);
    expect(find.text('Arkie 0.0.42 has been released.'), findsOneWidget);
    expect(find.text('See what changed'), findsOneWidget);
  });

  testWidgets('offers another try when the check could not be made', (tester) async {
    final releasesApi = FakeReleasesApi(latestReleaseTag: Err(Exception('offline')));
    final cubit = buildCubit(releasesApi: releasesApi);
    addTearDown(cubit.close);
    await pumpPanel(tester, cubit);
    await cubit.checkForUpdate();
    await tester.pump();

    await tester.tap(find.text('Try again'));
    await tester.pump();

    expect(find.text('unknown'), findsOneWidget);
    expect(releasesApi.fetchLatestReleaseTagCallCount, 2);
  });
}
