import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

class ReleaseGateValidation {
  bool hasBlockingState(List<ReleaseGateResult> gates) {
    if (gates.isEmpty) return true;
    for (final gate in gates) {
      if (gate.status != ReleaseGateStatus.pass) return true;
    }
    return false;
  }
}
