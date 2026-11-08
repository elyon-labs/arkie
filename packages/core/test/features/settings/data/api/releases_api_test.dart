import 'package:arkie_core/features/settings/data/api/releases_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  ReleasesApi buildSubject(Future<http.Response> Function(http.Request request) handler) {
    return ReleasesApi(client: MockClient(handler));
  }

  test('reads the tag of the latest release', () async {
    final subject = buildSubject((request) async {
      expect(request.url.host, 'api.github.com');
      expect(request.url.path, '/repos/elyon-labs/arkie/releases/latest');
      return http.Response('{"tag_name": "v0.0.42"}', 200);
    });

    final result = await subject.fetchLatestReleaseTag();

    expect(result.unwrap(), 'v0.0.42');
  });

  test('fails when GitHub does not answer with a release', () async {
    final subject = buildSubject((_) async => http.Response('Not Found', 404));

    final result = await subject.fetchLatestReleaseTag();

    expect(result.isErr(), isTrue);
  });

  test('fails when the release carries no tag', () async {
    final subject = buildSubject((_) async => http.Response('{"name": "Arkie"}', 200));

    final result = await subject.fetchLatestReleaseTag();

    expect(result.isErr(), isTrue);
  });

  test('fails when the answer is not a release at all', () async {
    final subject = buildSubject((_) async => http.Response('[]', 200));

    final result = await subject.fetchLatestReleaseTag();

    expect(result.isErr(), isTrue);
  });

  test('fails rather than throwing when the request cannot be made', () async {
    final subject = buildSubject((_) async => throw http.ClientException('offline'));

    final result = await subject.fetchLatestReleaseTag();

    expect(result.isErr(), isTrue);
  });
}
