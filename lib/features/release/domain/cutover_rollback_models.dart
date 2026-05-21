enum OperationStatus { hold, cutoverCompleted, rollbackCompleted }

enum RollbackSeverity { critical, high, medium }

class CutoverRun {
  const CutoverRun({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.status,
  });

  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final OperationStatus status;
}

class RollbackRun {
  const RollbackRun({
    required this.id,
    required this.triggeredAt,
    required this.completedAt,
    required this.severity,
    required this.owner,
    required this.reason,
    required this.status,
  });

  final String id;
  final DateTime triggeredAt;
  final DateTime completedAt;
  final RollbackSeverity severity;
  final String owner;
  final String reason;
  final OperationStatus status;
}

class RollbackVerificationReport {
  const RollbackVerificationReport({
    required this.id,
    required this.rollbackRunId,
    required this.generatedAt,
    required this.signals,
    required this.result,
  });

  final String id;
  final String rollbackRunId;
  final DateTime generatedAt;
  final Map<String, bool> signals;
  final bool result;
}
