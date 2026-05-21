enum ReleaseDecision { ready, notReady }

enum ReleaseGateStatus { pass, fail, missing, stale }

enum ReleaseBlockerSeverity { critical, high, medium }

enum ReleaseBlockerArea {
  auth,
  transactions,
  localization,
  quality,
  operations,
}

class ReleaseGateResult {
  const ReleaseGateResult({
    required this.gateName,
    required this.status,
    required this.evidenceRef,
    required this.checkedAt,
    required this.owner,
  });

  final String gateName;
  final ReleaseGateStatus status;
  final String evidenceRef;
  final DateTime checkedAt;
  final String owner;
}

class ReleaseBlocker {
  const ReleaseBlocker({
    required this.gateName,
    required this.area,
    required this.severity,
    required this.owner,
    required this.remediation,
    this.resolved = false,
  });

  final String gateName;
  final ReleaseBlockerArea area;
  final ReleaseBlockerSeverity severity;
  final String owner;
  final String remediation;
  final bool resolved;
}

class ReleaseReadinessRun {
  const ReleaseReadinessRun({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.result,
    required this.initiatedBy,
    required this.gates,
    required this.blockers,
  });

  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final ReleaseDecision result;
  final String initiatedBy;
  final List<ReleaseGateResult> gates;
  final List<ReleaseBlocker> blockers;
}

class ReleaseDecisionRecord {
  const ReleaseDecisionRecord({
    required this.runId,
    required this.publishedAt,
    required this.decision,
    required this.summary,
    required this.evidenceIndex,
  });

  final String runId;
  final DateTime publishedAt;
  final ReleaseDecision decision;
  final String summary;
  final List<Map<String, String>> evidenceIndex;
}
