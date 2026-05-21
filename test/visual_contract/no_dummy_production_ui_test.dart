import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production UI widgets do not contain dummy or placeholder markers', () {
    final projectRoot = Directory.current.path;
    final roots = <String>[
      '$projectRoot${Platform.pathSeparator}lib${Platform.pathSeparator}features',
      '$projectRoot${Platform.pathSeparator}lib${Platform.pathSeparator}shared',
    ];
    const bannedMarkers = <String>[
      'placeholder',
      'dummy',
      'demo-',
      'demo_',
      'lorem ipsum',
    ];

    final violations = <String>[];
    for (final root in roots) {
      final directory = Directory(root);
      if (!directory.existsSync()) {
        continue;
      }

      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }

        final path = entity.path.replaceAll(r'\', '/');
        if (path.contains('/data/')) {
          continue;
        }

        final content = entity
            .readAsStringSync()
            .toLowerCase()
            .replaceAll('placeholderfadeinduration', '')
            .replaceAll('placeholder:', '');
        for (final marker in bannedMarkers) {
          if (content.contains(marker)) {
            violations.add('$path -> $marker');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: violations.isEmpty ? null : violations.join('\n'),
    );
  });
}
