import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/observability_models.dart';
import 'package:qitak_app/features/release/domain/observability_services.dart';

void main() {
  test('alert service returns list without crashing', () {
    final snapshot = ReleaseHealthService().snapshot();
    final alerts = ReleaseAlertService().evaluate(snapshot);
    expect(alerts, isA<List<ReleaseAlert>>());
  });
}
