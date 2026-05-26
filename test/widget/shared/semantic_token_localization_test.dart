import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/generated/l10n.dart';

void main() {
  testWidgets('seller semantic token localizes in english', (tester) async {
    await tester.pumpWidget(const _TokenApp(locale: Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('seller_label_verified'), findsNothing);
    expect(find.text('Verified seller'), findsOneWidget);
  });

  testWidgets('seller semantic token localizes in arabic', (tester) async {
    await tester.pumpWidget(const _TokenApp(locale: Locale('ar')));
    await tester.pumpAndSettle();
    final rendered = tester.widget<Text>(find.byType(Text)).data ?? '';
    expect(rendered, isNotEmpty);
    expect(rendered, isNot('seller_label_verified'));
  });

  testWidgets('seller semantic token localizes in french', (tester) async {
    await tester.pumpWidget(const _TokenApp(locale: Locale('fr')));
    await tester.pumpAndSettle();
    final rendered = tester.widget<Text>(find.byType(Text)).data ?? '';
    expect(rendered, isNotEmpty);
    expect(rendered, isNot('seller_label_verified'));
  });
}

class _TokenApp extends StatelessWidget {
  const _TokenApp({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Text(
              S
                  .of(context)
                  .localMarketplaceSellerLabel('seller_label_verified'),
            ),
          );
        },
      ),
    );
  }
}
