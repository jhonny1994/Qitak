import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/observability/sentry_config.dart';

void main() {
  test('isConfigured is false when SENTRY_DSN is absent', () {
    expect(SentryConfig.isConfigured, isFalse);
  });

  test('setUserContext does not throw without Sentry initialization', () {
    expect(() => SentryConfig.setUserContext('buyer'), returnsNormally);
  });

  test('clearUserContext does not throw without Sentry initialization', () {
    expect(SentryConfig.clearUserContext, returnsNormally);
  });
}
