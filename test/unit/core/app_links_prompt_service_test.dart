import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/deep_links/app_links_prompt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // TestWidgetsFlutterBinding is initialized globally by flutter_test_config.dart.

  const channel = MethodChannel('com.carbodex.qitak/app_links');

  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  group('AppLinksPromptService', () {
    test('shouldPrompt() returns false on non-Android platforms', () async {
      // Test runner is always non-Android, so Platform.isAndroid is false.
      expect(await AppLinksPromptService.shouldPrompt(), isFalse);
    });

    test('markPrompted() writes the prefs key', () async {
      await AppLinksPromptService.markPrompted();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('app_links_settings_prompted'), isTrue);
    });

    test(
      'shouldPrompt() returns false when prefs key is already set',
      () async {
        SharedPreferences.setMockInitialValues(
          const <String, Object>{'app_links_settings_prompted': true},
        );
        expect(await AppLinksPromptService.shouldPrompt(), isFalse);
      },
    );

    test(
      'openSettings() invokes openDefaultAppsSettings on the channel',
      () async {
        String? invokedMethod;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              invokedMethod = call.method;
              return null;
            });
        addTearDown(
          () => TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null),
        );

        await AppLinksPromptService.openSettings();
        expect(invokedMethod, 'openDefaultAppsSettings');
      },
    );

    test(
      'openSettings() does not throw when no channel handler is registered',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);

        await expectLater(AppLinksPromptService.openSettings(), completes);
      },
    );
  });
}
