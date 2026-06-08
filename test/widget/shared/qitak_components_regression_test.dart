import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

void main() {
  Widget buildShell(
    Widget child, {
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: Scaffold(body: child),
    );
  }

  testWidgets('light and dark themes expose adaptive surface roles', (
    tester,
  ) async {
    for (final mode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(
        buildShell(
          Builder(
            builder: (context) {
              final tokens = context.qitakTokens;
              expect(tokens.page, isNot(tokens.object));
              expect(tokens.object, isNot(tokens.raised));
              expect(tokens.spacingMd, 16);
              expect(tokens.objectRadius, lessThan(tokens.sheetRadius));
              return const SizedBox.shrink();
            },
          ),
          themeMode: mode,
        ),
      );
    }
  });

  testWidgets('flat section and object card use different treatments', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildShell(
        const Column(
          children: [
            QitakSurface(
              key: Key('flat-surface'),
              role: QitakSurfaceRole.section,
              child: Text('Section'),
            ),
            QitakSurface(
              key: Key('object-surface'),
              role: QitakSurfaceRole.object,
              child: Text('Object'),
            ),
          ],
        ),
      ),
    );

    final flat = tester.widget<Ink>(
      find.descendant(
        of: find.byKey(const Key('flat-surface')),
        matching: find.byType(Ink),
      ),
    );
    final object = tester.widget<Ink>(
      find.descendant(
        of: find.byKey(const Key('object-surface')),
        matching: find.byType(Ink),
      ),
    );
    expect(flat.decoration, isNot(equals(object.decoration)));
  });

  testWidgets(
    'detail row, required form group, and dropdown error styling render',
    (
      tester,
    ) async {
      await tester.pumpWidget(
        buildShell(
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QitakDetailRow(label: 'Year', value: '2021'),
                SizedBox(height: 16),
                QitakFormGroup(
                  label: 'Brand',
                  required: true,
                  child: TextField(),
                ),
                SizedBox(height: 16),
                QitakDropdownField<String>(
                  errorText: 'err',
                  items: [
                    DropdownMenuItem(value: 'a', child: Text('A')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Year'), findsOneWidget);
      expect(find.text('2021'), findsOneWidget);
      expect(
        tester.getSize(find.byType(QitakDetailRow)).height,
        greaterThanOrEqualTo(44),
      );
      expect(find.text('*'), findsOneWidget);

      final decorator = tester
          .widgetList<InputDecorator>(
            find.byType(InputDecorator),
          )
          .last;
      final border = decorator.decoration.enabledBorder! as OutlineInputBorder;
      final context = tester.element(find.byType(QitakDropdownField<String>));

      expect(border.borderSide.color, Theme.of(context).colorScheme.error);
      expect(border.borderSide.width, 1.5);
    },
  );

  testWidgets('QitakPanel light mode uses subtle border and no glow', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildShell(
        const Padding(
          padding: EdgeInsets.all(24),
          child: QitakPanel(child: SizedBox(height: 48)),
        ),
      ),
    );

    final ink = tester.widget<Ink>(find.byType(Ink).first);
    final decoration = ink.decoration! as BoxDecoration;

    expect(decoration.boxShadow, isEmpty);
    expect(decoration.border, isNotNull);
  });
}
