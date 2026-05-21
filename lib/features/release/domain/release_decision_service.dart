import 'package:qitak_app/features/release/domain/release_gate_validation.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

class ReleaseDecisionService {
  ReleaseDecisionService(this.validation);

  final ReleaseGateValidation validation;

  ReleaseDecision decide(List<ReleaseGateResult> gates) {
    return validation.hasBlockingState(gates)
        ? ReleaseDecision.notReady
        : ReleaseDecision.ready;
  }
}
