import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/launch_checklist_service.dart';
import 'package:qitak_app/features/release/domain/launch_operations_models.dart';

void main() {
  test('launch checklist produces go for passing prerequisites', () {
    final service = LaunchChecklistService();
    final decision = service.evaluate(const [
      ChecklistPrerequisite(
        name: 'analyze',
        status: SignalStatus.pass,
        owner: 'mobile',
        evidenceRef: 'reports/release/gate-results.md',
      ),
    ]);
    expect(decision, LaunchDecision.go);
  });
}
