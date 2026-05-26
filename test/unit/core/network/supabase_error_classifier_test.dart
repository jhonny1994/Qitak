import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:qitak_app/core/network/supabase_error_classifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('classifyAuthException', () {
    test('maps invalid_credentials to invalidCredentials', () {
      const error = AuthException('invalid_credentials', statusCode: '400');
      expect(classifyAuthException(error), AppErrorCode.invalidCredentials);
    });

    test('maps over_request_rate_limit to rateLimited', () {
      const error = AuthException(
        'over_request_rate_limit',
        statusCode: '429',
      );
      expect(classifyAuthException(error), AppErrorCode.rateLimited);
    });
  });

  group('classifyPostgrestException', () {
    test('maps 23505 to conflict', () {
      const error = PostgrestException(
        message: 'duplicate key value violates unique constraint',
        code: '23505',
        details: '',
      );
      expect(classifyPostgrestException(error), AppErrorCode.conflict);
    });

    test('maps 42501 to permissionDenied', () {
      const error = PostgrestException(
        message: 'permission denied',
        code: '42501',
        details: '',
      );
      expect(classifyPostgrestException(error), AppErrorCode.permissionDenied);
    });

    test('maps PGRST116 to notFound', () {
      const error = PostgrestException(
        message: 'JSON object requested, multiple (or no) rows returned',
        code: 'PGRST116',
        details: '',
      );
      expect(classifyPostgrestException(error), AppErrorCode.notFound);
    });
  });

  group('classifyStorageErrorCode', () {
    test('maps AccessDenied to permissionDenied', () {
      expect(
        classifyStorageErrorCode('AccessDenied'),
        AppErrorCode.permissionDenied,
      );
    });

    test('maps ResourceAlreadyExists to conflict', () {
      expect(
        classifyStorageErrorCode('ResourceAlreadyExists'),
        AppErrorCode.conflict,
      );
    });

    test('maps NoSuchBucket to notFound', () {
      expect(classifyStorageErrorCode('NoSuchBucket'), AppErrorCode.notFound);
    });
  });

  group('classifyNetworkException', () {
    test('maps SocketException to networkUnavailable', () {
      expect(
        classifyNetworkException(const SocketException('offline')),
        AppErrorCode.networkUnavailable,
      );
    });

    test('maps ClientException to networkUnavailable', () {
      expect(
        classifyNetworkException(ClientException('network failed')),
        AppErrorCode.networkUnavailable,
      );
    });
  });
}
