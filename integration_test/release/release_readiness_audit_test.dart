import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/data/release_evidence_repository.dart';
import 'package:qitak_app/features/release/data/release_gate_runner.dart';
import 'package:qitak_app/features/release/domain/release_blocker_mapper.dart';
import 'package:qitak_app/features/release/domain/release_decision_service.dart';
import 'package:qitak_app/features/release/domain/release_gate_validation.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';
import 'package:qitak_app/features/release/domain/run_release_readiness.dart';

void main() {
  test('run has id, decision, and evidence refs', () async {
    final runner = RunReleaseReadiness(
      gateRunner: ReleaseGateRunnerImpl(ReleaseEvidenceRepository()),
      decisionService: ReleaseDecisionService(ReleaseGateValidation()),
      blockerMapper: ReleaseBlockerMapper(),
    );
    final run = await runner.call(initiatedBy: 'integration-test');
    expect(run.id, isNotEmpty);
    expect(run.result, anyOf(ReleaseDecision.ready, ReleaseDecision.notReady));
    expect(run.gates, isNotEmpty);
    expect(run.gates.first.evidenceRef, contains('reports/release/'));
  });
}
