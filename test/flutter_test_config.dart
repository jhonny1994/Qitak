import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _testFontAssets = <String, List<String>>{
  'Cairo': <String>['assets/fonts/cairo/Cairo-Variable.ttf'],
  'Inter': <String>[
    'assets/fonts/inter/Inter-Variable.ttf',
    'assets/fonts/inter/Inter-Italic-Variable.ttf',
  ],
  'MaterialIcons': <String>['fonts/MaterialIcons-Regular.otf'],
};

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadBundledFonts();
  await testMain();
}

Future<void> _loadBundledFonts() async {
  for (final entry in _testFontAssets.entries) {
    final loader = FontLoader(entry.key);
    for (final asset in entry.value) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
