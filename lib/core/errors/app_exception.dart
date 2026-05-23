class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class EmailConfirmationRequiredException extends AppException {
  const EmailConfirmationRequiredException({
    required this.email,
    required String message,
  }) : super(message);

  final String email;
}
