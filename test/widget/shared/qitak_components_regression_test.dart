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
