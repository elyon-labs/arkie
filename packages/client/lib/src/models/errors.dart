/// {@template authorization_exception}
/// Returned when the user is not authorized to perform the requested operation.
/// {@endtemplate}
class AuthorizationException implements Exception {
  /// {@macro authorization_exception}
  AuthorizationException(this.message);

  /// The message associated with the exception.
  final String message;

  @override
  String toString() {
    return 'AuthorizationException: $message';
  }
}

/// {@template command_timeout_exception}
/// Returned when a command sent to the server times out.
/// The message associated with the exception provides details about the timeout.
/// {@endtemplate}
class CommandTimeoutException implements Exception {
  /// {@macro command_timeout_exception}
  CommandTimeoutException(this.message);

  /// The message associated with the exception.
  final String message;

  @override
  String toString() {
    return 'CommandTimeoutException: $message';
  }
}

/// {@template socket_closed_exception}
/// Returned when an operation is attempted on a closed socket.
/// {@endtemplate}
class SocketClosedException implements Exception {
  /// {@macro socket_closed_exception}
  SocketClosedException(this.message);

  /// The message associated with the exception.
  final String message;

  @override
  String toString() {
    return 'SocketClosedException: $message';
  }
}
