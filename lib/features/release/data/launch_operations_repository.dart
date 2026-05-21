import 'dart:convert';
import 'dart:io';

import 'package:qitak_app/features/release/domain/launch_operations_models.dart';

class LaunchOperationsRepository {
  Future<File> writeChecklist(LaunchChecklistRun run) async {
    final dir = await _ensureDir();
    final file = File('${dir.path}/checklist_${run.id}.json');
    await file.writeAsString(
      jsonEncode({
        'id': run.id,
        'started_at': run.startedAt.toIso8601String(),
        'ended_at': run.endedAt.toIso8601String(),
        'decision': run.decision.name,
        'prerequisites': run.prerequisites
            .map(
              (p) => {
                'name': p.name,
                'status': p.status.name,
                'owner': p.owner,
                'evidence_ref': p.evidenceRef,
              },
            )
            .toList(),
      }),
    );
    return file;
  }

  Future<File> writeSnapshot(MonitoringSnapshot snapshot) async {
    final dir = await _ensureDir();
    final file = File('${dir.path}/snapshot_${snapshot.id}.json');
    await file.writeAsString(
      jsonEncode({
        'id': snapshot.id,
        'generated_at': snapshot.generatedAt.toIso8601String(),
        'release_run_id': snapshot.releaseRunId,
        'signals': snapshot.signals.map((k, v) => MapEntry(k, v.name)),
      }),
    );
    return file;
  }

  Future<File> writeIncident(LaunchIncident incident) async {
    final dir = await _ensureDir();
    final file = File('${dir.path}/incident_${incident.id}.json');
    await file.writeAsString(
      jsonEncode({
        'id': incident.id,
        'severity': incident.severity.name,
        'owner': incident.owner,
        'action': incident.action,
        'created_at': incident.createdAt.toIso8601String(),
      }),
    );
    return file;
  }

  Future<Directory> _ensureDir() async {
    final dir = Directory('reports/release/operations');
    await dir.create(recursive: true);
    return dir;
  }
}
