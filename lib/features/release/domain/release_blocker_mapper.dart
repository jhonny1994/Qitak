import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

class ReleaseBlockerMapper {
  List<ReleaseBlocker> fromGateResults(List<ReleaseGateResult> gates) {
    final blockers = <ReleaseBlocker>[];
    for (final gate in gates) {
      if (gate.status == ReleaseGateStatus.pass) continue;
      blockers.add(
        ReleaseBlocker(
          gateName: gate.gateName,
          area: _areaFor(gate.gateName),
          severity: gate.status == ReleaseGateStatus.fail
              ? ReleaseBlockerSeverity.critical
              : ReleaseBlockerSeverity.high,
          owner: gate.owner,
          remediation: 'Fix ${gate.gateName} and rerun readiness.',
        ),
      );
    }
    return blockers;
  }

  ReleaseBlockerArea _areaFor(String gateName) {
    final text = gateName.toLowerCase();
    if (text.contains('db') ||
        text.contains('supabase') ||
        text.contains('rls')) {
      return ReleaseBlockerArea.transactions;
    }
    if (text.contains('integration')) return ReleaseBlockerArea.operations;
    if (text.contains('analyze') || text.contains('lint')) {
      return ReleaseBlockerArea.quality;
    }
    if (text.contains('l10n')) return ReleaseBlockerArea.localization;
    return ReleaseBlockerArea.auth;
  }
}
