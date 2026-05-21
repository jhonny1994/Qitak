import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/discovery/presentation/home_screen.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('restores buyer session and lands on home', (tester) async {
    final app = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
