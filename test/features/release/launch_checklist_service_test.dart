import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/launch_checklist_service.dart';
import 'package:qitak_app/features/release/domain/launch_operations_models.dart';

void main() {
  test('returns go when all prerequisites pass', () {
    final service = LaunchChecklistService();
    final decision = service.evaluate(const [
      ChecklistPrerequisite(
        name: 'a',
        status: SignalStatus.pass,
        owner: 'x',
        evidenceRef: 'r',
      ),
    ]);
    expect(decision, LaunchDecision.go);
  });
}
