import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

void main() {
  Widget buildShell(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      home: Scaffold(body: child),
    );
  }

  testWidgets(
    'confirmation modal renders content and returns false on cancel',
    (
      tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        buildShell(
          Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => const QitakConfirmationModal(
                    title: 'Delete listing',
                    body: 'Are you sure? This action cannot be undone.',
                    confirmLabel: 'Delete',
                    cancelLabel: 'Cancel',
                    isDestructive: true,
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete listing'), findsOneWidget);
      expect(
        find.text('Are you sure? This action cannot be undone.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    },
  );

  testWidgets('confirmation modal returns true on confirm', (tester) async {
    bool? result;

    await tester.pumpWidget(
      buildShell(
        Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => const QitakConfirmationModal(
                  title: 'Cancel transaction',
                  body: 'Are you sure you want to cancel this transaction?',
                  confirmLabel: 'Confirm',
                  cancelLabel: 'Back',
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets(
    'destructive confirmation styles confirm button with error color',
    (tester) async {
      await tester.pumpWidget(
        buildShell(
          const QitakConfirmationModal(
            title: 'Delete listing',
            body: 'Are you sure? This action cannot be undone.',
            confirmLabel: 'Delete',
            cancelLabel: 'Cancel',
            isDestructive: true,
          ),
        ),
      );

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete'),
      );
      final context = tester.element(find.byType(QitakConfirmationModal));
      final colorScheme = Theme.of(context).colorScheme;

      expect(
        button.style?.backgroundColor?.resolve(<WidgetState>{}),
        colorScheme.error,
      );
      expect(
        button.style?.foregroundColor?.resolve(<WidgetState>{}),
        colorScheme.onError,
      );
    },
  );
}
