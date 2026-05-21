import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

void main() {
  Widget buildShell(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: Scaffold(body: child),
    );
  }

  testWidgets('shared primitives meet tap target and label guidance', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildShell(
        ListView(
          padding: const EdgeInsets.all(24),
          children: [
            QitakListingSurface(
              title: 'Brake Pad Set',
              price: '7,500 DZD',
              subtitle: 'Business seller | Oran',
              ratingLabel: '4.1',
              actions: [
                FilledButton(onPressed: () {}, child: const Text('Start deal')),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Message seller'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const QitakStateMessage(
              title: 'No saved listings',
              message: 'Save a listing to see it here later.',
              action: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: null,
                  child: Text('Explore listings'),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}
