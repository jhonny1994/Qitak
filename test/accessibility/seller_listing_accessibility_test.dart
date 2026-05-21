import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/listings/presentation/listing_form_screen.dart';

import '../test_bootstrap.dart';

void main() {
  testWidgets('listing form meets tap target guidance', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ListingFormScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump(const Duration(milliseconds: 220));

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  });
}
