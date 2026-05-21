import 'package:qitak_app/features/release/domain/cutover_rollback_models.dart';

class CutoverService {
  CutoverRun run({required bool prechecksPass}) {
    final now = DateTime.now().toUtc();
    return CutoverRun(
      id: 'cut-${now.millisecondsSinceEpoch}',
      startedAt: now,
      endedAt: DateTime.now().toUtc(),
      status: prechecksPass
          ? OperationStatus.cutoverCompleted
          : OperationStatus.hold,
    );
  }
}
