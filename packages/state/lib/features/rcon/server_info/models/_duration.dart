extension DurationX on Duration {
  String get banDescription {
    if (inSeconds <= 0) {
      return 'permanent';
    } else if (inHours < 1) {
      return '${inMinutes}m';
    } else if (inDays < 1) {
      return '${inHours}h';
    } else {
      return '${inDays}d';
    }
  }
}
