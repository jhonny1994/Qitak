import 'package:qitak_app/features/release/domain/launch_operations_models.dart';

class LaunchIncidentService {
  LaunchIncident build({
    required IncidentSeverity severity,
    required String owner,
    required String action,
  }) {
    final now = DateTime.now().toUtc();
    final normalizedOwner = owner.trim();
    final normalizedAction = action.trim();
    if (severity == IncidentSeverity.critical &&
        (normalizedOwner.isEmpty || normalizedAction.isEmpty)) {
      throw ArgumentError(
        'Critical incidents require non-empty owner and action.',
      );
    }
    return LaunchIncident(
      id: 'inc-${now.millisecondsSinceEpoch}',
      severity: severity,
      owner: normalizedOwner,
      action: normalizedAction,
      createdAt: now,
    );
  }
}
