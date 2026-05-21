import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/observability_services.dart';

void main() {
  test('health snapshot has mandatory signals', () {
    final snapshot = ReleaseHealthService().snapshot();
    expect(snapshot.signals.containsKey('auth_success_rate'), isTrue);
    expect(snapshot.signals.containsKey('transaction_success_rate'), isTrue);
    expect(snapshot.signals.containsKey('message_delivery_rate'), isTrue);
  });
}
