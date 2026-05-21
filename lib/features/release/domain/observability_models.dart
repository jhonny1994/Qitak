enum AlertSeverity { critical, high, medium }

class ReleaseHealthSnapshot {
  const ReleaseHealthSnapshot({
    required this.id,
    required this.generatedAt,
    required this.signals,
  });
  final String id;
  final DateTime generatedAt;
  final Map<String, double> signals;
}

class ReleaseAlert {
  const ReleaseAlert({
    required this.id,
    required this.severity,
    required this.metric,
    required this.threshold,
    required this.value,
    required this.owner,
    this.acknowledgedAt,
  });
  final String id;
  final AlertSeverity severity;
  final String metric;
  final double threshold;
  final double value;
  final String owner;
  final DateTime? acknowledgedAt;
}

class ReleaseStableReport {
  const ReleaseStableReport({
    required this.id,
    required this.decision,
    required this.summary,
    required this.generatedAt,
  });
  final String id;
  final String decision;
  final String summary;
  final DateTime generatedAt;
}
