import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/launch_incident_service.dart';
import 'package:qitak_app/features/release/domain/launch_operations_models.dart';

void main() {
  test('critical incidents require owner and action', () {
    final service = LaunchIncidentService();
    expect(
      () => service.build(
        severity: IncidentSeverity.critical,
        owner: '',
        action: '',
      ),
      throwsArgumentError,
    );
  });
}
