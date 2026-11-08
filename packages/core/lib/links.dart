/// The addresses Arkie points people at from inside the apps.
///
/// Both apps show some of these, and the website publishes the same set, so
/// they are written down once here rather than typed into each widget.
abstract final class ArkieLinks {
  static const String repository = 'https://github.com/elyon-labs/arkie';

  /// Where to file a bug or a feature request.
  static const String issues = '$repository/issues/new/choose';

  /// The releases themselves, with the installers attached to each.
  static const String releases = '$repository/releases';

  /// The release notes as a reader wants them: what changed in each version,
  /// newest first, without the installer tables.
  static const String whatsNew = 'https://arkie.elyon-labs.com/releases';
}
