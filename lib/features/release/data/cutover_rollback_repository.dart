import 'dart:convert';
import 'dart:io';

import 'package:qitak_app/features/release/domain/cutover_rollback_models.dart';

class CutoverRollbackRepository {
  Future<void> persistCutover(CutoverRun run) async {
    final dir = await _dir();
    final file = File('${dir.path}/cutover_${run.id}.json');
    await file.writeAsString(
      jsonEncode({
        'id': run.id,
        'started_at': run.startedAt.toIso8601String(),
        'ended_at': run.endedAt.toIso8601String(),
        'status': run.status.name,
      }),
    );
  }

  Future<void> persistRollback(RollbackRun run) async {
    final dir = await _dir();
    final file = File('${dir.path}/rollback_${run.id}.json');
    await file.writeAsString(
      jsonEncode({
        'id': run.id,
        'triggered_at': run.triggeredAt.toIso8601String(),
        'completed_at': run.completedAt.toIso8601String(),
        'severity': run.severity.name,
        'owner': run.owner,
        'reason': run.reason,
        'status': run.status.name,
      }),
    );
  }

  Future<void> persistVerification(RollbackVerificationReport report) async {
    final dir = await _dir();
    final file = File('${dir.path}/verification_${report.id}.json');
    await file.writeAsString(
      jsonEncode({
        'id': report.id,
        'rollback_run_id': report.rollbackRunId,
        'generated_at': report.generatedAt.toIso8601String(),
        'signals': report.signals,
        'result': report.result,
      }),
    );
  }

  Future<Directory> _dir() async {
    final dir = Directory('reports/release/operations');
    await dir.create(recursive: true);
    return dir;
  }
}
