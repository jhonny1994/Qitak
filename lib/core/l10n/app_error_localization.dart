import 'package:flutter/widgets.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/app_error_code.dart';

extension AppErrorLocalizationX on BuildContext {
  String appErrorMessage(AppErrorCode code) {
    switch (code) {
      case AppErrorCode.sessionNotFound:
        return l10n.authErrorSessionNotFound;
      case AppErrorCode.invalidCredentials:
        return l10n.authErrorInvalidEmailOrPassword;
      case AppErrorCode.emailNotConfirmed:
        return l10n.authErrorConfirmEmailBeforeSignIn;
      case AppErrorCode.accountAlreadyExists:
        return l10n.authErrorEmailAlreadyExists;
      case AppErrorCode.passwordPolicyViolation:
        return l10n.authErrorPasswordRequirements;
      case AppErrorCode.invalidEmail:
        return l10n.emailValidationError;
      case AppErrorCode.profileSetupBlocked:
        return l10n.authErrorProfileSetupBlockedPolicy;
      case AppErrorCode.permissionDenied:
        return l10n.authErrorProfileSetupBlockedRls;
      case AppErrorCode.rateLimited:
        return l10n.authErrorUnableSignIn;
      case AppErrorCode.networkUnavailable:
        return l10n.errorNetworkUnavailable;
      case AppErrorCode.contractUnavailable:
        return l10n.errorStateTitle;
      case AppErrorCode.conflict:
      case AppErrorCode.notFound:
      case AppErrorCode.validationFailed:
      case AppErrorCode.unknown:
        return l10n.errorStateTitle;
    }
  }

  String semanticTokenLabel(String token) {
    switch (token) {
      case 'seller_label_verified':
        return l10n.localSellerLabelVerified;
      case 'seller_label_business':
        return l10n.localSellerLabelBusiness;
      default:
        return token;
    }
  }

  String appExceptionMessage(AppException error) {
    final code = error.code ?? appErrorCodeFromToken(error.message);
    if (code != null) {
      return appErrorMessage(code);
    }
    return error.message;
  }
}
