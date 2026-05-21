import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_list_screen.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('shows empty state when no listing conversations exist', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ConversationListScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Listing conversations'), findsOneWidget);
    expect(
      find.textContaining('No listing-anchored conversations yet'),
      findsOneWidget,
    );
    expect(find.text('Ready'), findsNothing);
  });
}
