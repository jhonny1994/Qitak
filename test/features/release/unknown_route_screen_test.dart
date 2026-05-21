import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/presentation/unknown_route_screen.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('shows unknown route fallback screen', (tester) async {
    await tester.pumpWidget(
      const TestMaterialShell(
        child: UnknownRouteScreen(requestedPath: '/invalid/path'),
      ),
    );
    expect(find.textContaining('/invalid/path'), findsOneWidget);
  });
}
