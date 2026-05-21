import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/presentation/risk_action_confirmation_dialog.dart';
import 'package:qitak_app/generated/l10n.dart';

void main() {
  testWidgets('renders risk confirmation dialog title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () {
                unawaited(
                  showRiskActionConfirmationDialog(
                    context,
                    actionLabel: 'rollback',
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Confirm'), findsWidgets);
  });
}
