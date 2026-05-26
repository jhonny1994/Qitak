enum AppErrorCode {
  unknown,
  sessionNotFound,
  invalidCredentials,
  emailNotConfirmed,
  accountAlreadyExists,
  passwordPolicyViolation,
  invalidEmail,
  profileSetupBlocked,
  permissionDenied,
  conflict,
  notFound,
  validationFailed,
  rateLimited,
  networkUnavailable,
  contractUnavailable,
}

extension AppErrorCodeX on AppErrorCode {
  String get token {
    switch (this) {
      case AppErrorCode.unknown:
        return 'error_unknown';
      case AppErrorCode.sessionNotFound:
        return 'error_session_not_found';
      case AppErrorCode.invalidCredentials:
        return 'error_invalid_credentials';
      case AppErrorCode.emailNotConfirmed:
        return 'error_email_not_confirmed';
      case AppErrorCode.accountAlreadyExists:
        return 'error_account_exists';
      case AppErrorCode.passwordPolicyViolation:
        return 'error_password_policy';
      case AppErrorCode.invalidEmail:
        return 'error_invalid_email';
      case AppErrorCode.profileSetupBlocked:
        return 'error_profile_setup_blocked';
      case AppErrorCode.permissionDenied:
        return 'error_permission_denied';
      case AppErrorCode.conflict:
        return 'error_conflict';
      case AppErrorCode.notFound:
        return 'error_not_found';
      case AppErrorCode.validationFailed:
        return 'error_validation_failed';
      case AppErrorCode.rateLimited:
        return 'error_rate_limited';
      case AppErrorCode.networkUnavailable:
        return 'error_network_unavailable';
      case AppErrorCode.contractUnavailable:
        return 'error_contract_unavailable';
    }
  }
}

AppErrorCode? appErrorCodeFromToken(String token) {
  for (final code in AppErrorCode.values) {
    if (code.token == token) {
      return code;
    }
  }
  return null;
}
