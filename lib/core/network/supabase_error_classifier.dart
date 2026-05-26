import 'dart:io';

import 'package:http/http.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

AppErrorCode classifyAuthException(AuthException error) {
  final apiCode = _authApiCode(error);
  if (apiCode != null) {
    final mapped = _authCodeMap[apiCode];
    if (mapped != null) {
      return mapped;
    }
  }
  if ((error.statusCode ?? '').trim() == '429') {
    return AppErrorCode.rateLimited;
  }
  return AppErrorCode.unknown;
}

AppErrorCode classifyPostgrestException(PostgrestException error) {
  final code = (error.code ?? '').trim().toUpperCase();
  final exact = _postgrestExactCodeMap[code];
  if (exact != null) {
    return exact;
  }
  for (final prefix in _postgrestPrefixMap.entries) {
    if (code.startsWith(prefix.key)) {
      return prefix.value;
    }
  }
  return AppErrorCode.unknown;
}

AppErrorCode classifyStorageErrorCode(String? code) {
  final normalized = (code ?? '').trim();
  if (normalized.isEmpty) {
    return AppErrorCode.unknown;
  }
  final mapped = _storageCodeMap[normalized];
  if (mapped != null) {
    return mapped;
  }
  return AppErrorCode.unknown;
}

AppErrorCode classifyNetworkException(Object error) {
  if (error is SocketException || error is ClientException) {
    return AppErrorCode.networkUnavailable;
  }
  return AppErrorCode.unknown;
}

const Map<String, AppErrorCode> _authCodeMap = <String, AppErrorCode>{
  'invalid_credentials': AppErrorCode.invalidCredentials,
  'email_not_confirmed': AppErrorCode.emailNotConfirmed,
  'phone_not_confirmed': AppErrorCode.emailNotConfirmed,
  'email_exists': AppErrorCode.accountAlreadyExists,
  'phone_exists': AppErrorCode.accountAlreadyExists,
  'user_already_exists': AppErrorCode.accountAlreadyExists,
  'email_address_invalid': AppErrorCode.invalidEmail,
  'over_request_rate_limit': AppErrorCode.rateLimited,
  'over_email_send_rate_limit': AppErrorCode.rateLimited,
  'over_sms_send_rate_limit': AppErrorCode.rateLimited,
  'weak_password': AppErrorCode.passwordPolicyViolation,
  'bad_jwt': AppErrorCode.permissionDenied,
  'insufficient_aal': AppErrorCode.permissionDenied,
  'no_authorization': AppErrorCode.permissionDenied,
  'not_admin': AppErrorCode.permissionDenied,
  'captcha_failed': AppErrorCode.validationFailed,
  'conflict': AppErrorCode.conflict,
};

const Map<String, AppErrorCode> _postgrestExactCodeMap = <String, AppErrorCode>{
  '23505': AppErrorCode.conflict,
  '23503': AppErrorCode.validationFailed,
  '23514': AppErrorCode.validationFailed,
  '22P02': AppErrorCode.validationFailed,
  '42501': AppErrorCode.permissionDenied,
  '42P01': AppErrorCode.notFound,
  '42883': AppErrorCode.notFound,
  'P0001': AppErrorCode.validationFailed,
  'PGRST116': AppErrorCode.notFound,
};

const Map<String, AppErrorCode> _postgrestPrefixMap = <String, AppErrorCode>{
  '08': AppErrorCode.unknown,
  '09': AppErrorCode.unknown,
  '0L': AppErrorCode.permissionDenied,
  '0P': AppErrorCode.permissionDenied,
  '25': AppErrorCode.unknown,
  '28': AppErrorCode.permissionDenied,
  '2D': AppErrorCode.unknown,
  '38': AppErrorCode.unknown,
  '39': AppErrorCode.unknown,
  '3B': AppErrorCode.unknown,
  '40': AppErrorCode.unknown,
  '53': AppErrorCode.unknown,
  '54': AppErrorCode.unknown,
  '55': AppErrorCode.unknown,
  '57': AppErrorCode.unknown,
  '58': AppErrorCode.unknown,
  'F0': AppErrorCode.unknown,
  'HV': AppErrorCode.unknown,
  'P0': AppErrorCode.unknown,
  'XX': AppErrorCode.unknown,
};

const Map<String, AppErrorCode> _storageCodeMap = <String, AppErrorCode>{
  'NoSuchBucket': AppErrorCode.notFound,
  'NoSuchKey': AppErrorCode.notFound,
  'NoSuchUpload': AppErrorCode.notFound,
  'TenantNotFound': AppErrorCode.notFound,
  'ResourceAlreadyExists': AppErrorCode.conflict,
  'already_exists': AppErrorCode.conflict,
  'InvalidJWT': AppErrorCode.permissionDenied,
  'AccessDenied': AppErrorCode.permissionDenied,
  'InvalidSignature': AppErrorCode.permissionDenied,
  'SignatureDoesNotMatch': AppErrorCode.permissionDenied,
  'EntityTooLarge': AppErrorCode.validationFailed,
  'InvalidRequest': AppErrorCode.validationFailed,
  'InvalidChecksum': AppErrorCode.validationFailed,
  'MissingPart': AppErrorCode.validationFailed,
  'ResourceLocked': AppErrorCode.validationFailed,
  'SlowDown': AppErrorCode.rateLimited,
  'not_found': AppErrorCode.notFound,
  'unauthorized': AppErrorCode.permissionDenied,
};

String? _authApiCode(AuthException error) {
  final candidates = <String>{
    error.message.toLowerCase(),
    error.toString().toLowerCase(),
  };
  for (final code in _authCodeMap.keys) {
    for (final text in candidates) {
      if (text.contains(code)) {
        return code;
      }
    }
  }
  return null;
}
