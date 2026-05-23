import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/connectivity/connectivity_service.dart';

void main() {
  group('resolveOnlineStateForTesting', () {
    test('[none] → offline, lookup not called', () async {
      var lookupCalled = false;
      final result = await resolveOnlineStateForTesting(
        [ConnectivityResult.none],
        lookup: (_) async {
          lookupCalled = true;
          return [];
        },
      );
      expect(result, isFalse);
      expect(lookupCalled, isFalse);
    });

    test('active result + non-empty lookup → online', () async {
      final result = await resolveOnlineStateForTesting(
        [ConnectivityResult.wifi],
        lookup: (_) async => [InternetAddress('1.1.1.1')],
      );
      expect(result, isTrue);
    });

    test('active result + empty lookup response → offline', () async {
      final result = await resolveOnlineStateForTesting(
        [ConnectivityResult.wifi],
        lookup: (_) async => [],
      );
      expect(result, isFalse);
    });

    test('active result + lookup throws SocketException → offline', () async {
      final result = await resolveOnlineStateForTesting(
        [ConnectivityResult.wifi],
        lookup: (_) async => throw const SocketException('network unavailable'),
      );
      expect(result, isFalse);
    });

    test('active result + lookup times out → offline', () async {
      final result = await resolveOnlineStateForTesting(
        [ConnectivityResult.wifi],
        lookup: (_) => Future<List<InternetAddress>>.error(
          TimeoutException('lookup timed out', const Duration(seconds: 3)),
        ),
      );
      expect(result, isFalse);
    });

    test(
      'multiple results → lookup called, returns online when lookup succeeds',
      () async {
        var lookupCalled = false;
        final result = await resolveOnlineStateForTesting(
          [ConnectivityResult.wifi, ConnectivityResult.mobile],
          lookup: (_) async {
            lookupCalled = true;
            return [InternetAddress('1.1.1.1')];
          },
        );
        expect(lookupCalled, isTrue);
        expect(result, isTrue);
      },
    );
  });
}
