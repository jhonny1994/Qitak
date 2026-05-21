import 'package:qitak_app/features/release/domain/release_blocker_mapper.dart';
import 'package:qitak_app/features/release/domain/release_decision_service.dart';
import 'package:qitak_app/features/release/domain/release_readiness_contract.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

class RunReleaseReadiness {
  RunReleaseReadiness({
    required this.gateRunner,
    required this.decisionService,
    required this.blockerMapper,
  });

  final ReleaseGateRunner gateRunner;
  final ReleaseDecisionService decisionService;
  final ReleaseBlockerMapper blockerMapper;

  Future<ReleaseReadinessRun> call({required String initiatedBy}) async {
    final startedAt = DateTime.now().toUtc();
    final gates = await gateRunner.runAll();
    final decision = decisionService.decide(gates);
    final blockers = blockerMapper.fromGateResults(gates);
    return ReleaseReadinessRun(
      id: 'run-${startedAt.millisecondsSinceEpoch}',
      startedAt: startedAt,
      endedAt: DateTime.now().toUtc(),
      result: decision,
      initiatedBy: initiatedBy,
      gates: gates,
      blockers: blockers,
    );
  }
}
