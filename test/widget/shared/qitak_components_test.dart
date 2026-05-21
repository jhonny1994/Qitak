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

  testWidgets('listing surface renders premium content blocks', (tester) async {
    await tester.pumpWidget(
      buildShell(
        QitakListingSurface(
          title: 'Headlight Assembly',
          price: '18,500 DZD',
          subtitle: 'Verified seller | Bab Ezzouar',
          ratingLabel: '4.8',
          badges: const [
            QitakChip(label: 'Peugeot 308'),
            QitakChip(label: 'Alger'),
          ],
          actions: [
            FilledButton(onPressed: () {}, child: const Text('Buy')),
            OutlinedButton(onPressed: () {}, child: const Text('Message')),
          ],
        ),
      ),
    );

    expect(find.text('18,500 DZD'), findsOneWidget);
    expect(find.text('Headlight Assembly'), findsOneWidget);
    expect(find.text('Verified seller | Bab Ezzouar'), findsOneWidget);
    expect(find.text('Peugeot 308'), findsOneWidget);
    expect(find.text('Buy'), findsOneWidget);
  });

  testWidgets('form group shows helper and error text below input', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildShell(
        const Padding(
          padding: EdgeInsets.all(24),
          child: QitakFormGroup(
            label: 'Brand',
            helper: 'Choose the vehicle brand first.',
            error: 'Brand is required.',
            child: TextField(),
          ),
        ),
      ),
    );

    expect(find.text('Brand'), findsOneWidget);
    expect(find.text('Brand is required.'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('listing gallery keeps fallback media inside a hero shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildShell(
        const Padding(
          padding: EdgeInsets.all(24),
          child: QitakListingGallery(
            heroTag: 'listing-media-test',
          ),
        ),
      ),
    );

    final hero = tester.widget<Hero>(
      find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'listing-media-test',
      ),
    );

    expect(hero.tag, 'listing-media-test');
    expect(find.byType(QitakListingGallery), findsOneWidget);
  });

  testWidgets('pull to refresh wrapper exposes refresh behavior', (
    tester,
  ) async {
    var refreshCount = 0;

    await tester.pumpWidget(
      buildShell(
        QitakPullToRefresh(
          onRefresh: () async {
            refreshCount += 1;
          },
          slivers: const [
            SliverToBoxAdapter(
              child: SizedBox(height: 600, child: Text('Feed')),
            ),
          ],
        ),
      ),
    );

    await tester.drag(find.text('Feed'), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(refreshCount, 1);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
