enum LaunchDecision { go, hold }

enum SignalStatus { pass, fail, unknown }

enum IncidentSeverity { critical, high, medium }

class ChecklistPrerequisite {
  const ChecklistPrerequisite({
    required this.name,
    required this.status,
    required this.owner,
    required this.evidenceRef,
  });

  final String name;
  final SignalStatus status;
  final String owner;
  final String evidenceRef;
}

class LaunchChecklistRun {
  const LaunchChecklistRun({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.decision,
    required this.prerequisites,
  });

  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final LaunchDecision decision;
  final List<ChecklistPrerequisite> prerequisites;
}

class MonitoringSnapshot {
  const MonitoringSnapshot({
    required this.id,
    required this.generatedAt,
    required this.releaseRunId,
    required this.signals,
  });

  final String id;
  final DateTime generatedAt;
  final String releaseRunId;
  final Map<String, SignalStatus> signals;
}

class LaunchIncident {
  const LaunchIncident({
    required this.id,
    required this.severity,
    required this.owner,
    required this.action,
    required this.createdAt,
  });

  final String id;
  final IncidentSeverity severity;
  final String owner;
  final String action;
  final DateTime createdAt;
}
