import 'dart:convert';

import 'package:arkie_core/links.dart';
import 'package:http/http.dart' as http;
import 'package:oxidized/oxidized.dart';

/// The newest release Arkie has published, as GitHub reports it.
///
/// GitHub's `releases/latest` already skips drafts and prereleases, so what
/// comes back here is the version a person could actually be running.
class ReleasesApi {
  ReleasesApi({required http.Client client}) : _client = client;

  factory ReleasesApi.create() {
    return ReleasesApi(client: http.Client());
  }

  static final Uri _latestRelease = Uri.parse(
    'https://api.github.com/repos/elyon-labs/arkie/releases/latest',
  );

  /// Unauthenticated calls to GitHub are rate limited per address, so the check
  /// gives up quickly rather than leaving the screen waiting on it.
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  /// The tag of the newest published release, such as `v0.0.41`.
  Future<Result<String, Exception>> fetchLatestReleaseTag() async {
    return Result.asyncOf(() async {
      final response = await _client
          .get(_latestRelease, headers: const {'Accept': 'application/vnd.github+json'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('${ArkieLinks.releases} answered ${response.statusCode}');
      }

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        throw Exception('Unexpected release payload');
      }

      final tag = body['tag_name'];
      if (tag is! String || tag.isEmpty) {
        throw Exception('Release has no tag');
      }

      return tag;
    });
  }
}
