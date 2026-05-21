import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/release_decision_service.dart';
import 'package:qitak_app/features/release/domain/release_gate_validation.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

void main() {
  group('ReleaseDecisionService', () {
    final service = ReleaseDecisionService(ReleaseGateValidation());
    final now = DateTime.utc(2026, 5, 12);

    test('returns ready when all gates pass', () {
      final result = service.decide([
        ReleaseGateResult(
          gateName: 'analyze',
          status: ReleaseGateStatus.pass,
          evidenceRef: 'r1',
          checkedAt: now,
          owner: 'mobile',
        ),
      ]);
      expect(result, ReleaseDecision.ready);
    });

    test('returns notReady when one gate fails', () {
      final result = service.decide([
        ReleaseGateResult(
          gateName: 'db',
          status: ReleaseGateStatus.fail,
          evidenceRef: 'r1',
          checkedAt: now,
          owner: 'backend',
        ),
      ]);
      expect(result, ReleaseDecision.notReady);
    });
  });
}
