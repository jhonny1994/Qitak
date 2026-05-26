import 'package:qitak_app/core/network/app_error_code.dart';

class AppException implements Exception {
  const AppException(this.message, {this.code});

  factory AppException.fromCode(AppErrorCode code) {
    return AppException(code.token, code: code);
  }

  final String message;
  final AppErrorCode? code;

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
