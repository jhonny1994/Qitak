import 'package:qitak_app/features/release/domain/cutover_rollback_models.dart';

class RollbackService {
  RollbackRun trigger({
    required RollbackSeverity severity,
    required String owner,
    required String reason,
  }) {
    final now = DateTime.now().toUtc();
    return RollbackRun(
      id: 'rb-${now.millisecondsSinceEpoch}',
      triggeredAt: now,
      completedAt: DateTime.now().toUtc(),
      severity: severity,
      owner: owner,
      reason: reason,
      status: OperationStatus.rollbackCompleted,
    );
  }
}
