import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('entry performance smoke stays within spec budget in fake mode', (
    tester,
  ) async {
    final stopwatch = Stopwatch()..start();
    final app = await buildQitakApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    stopwatch.stop();

    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 3)));

    final signInStopwatch = Stopwatch()..start();
    final signedInApp = await buildQitakApp(
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
    );
    await tester.pumpWidget(signedInApp);
    await tester.pumpAndSettle();
    signInStopwatch.stop();

    expect(signInStopwatch.elapsed, lessThan(const Duration(seconds: 60)));
  });
}
