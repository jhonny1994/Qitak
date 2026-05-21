import 'dart:convert';
import 'dart:io';

import 'package:qitak_app/features/release/domain/observability_models.dart';

class ObservabilityRepository {
  Future<void> persistSnapshot(ReleaseHealthSnapshot snapshot) async {
    final dir = await _dir();
    final file = File('${dir.path}/health_${snapshot.id}.json');
    await file.writeAsString(
      jsonEncode({
        'id': snapshot.id,
        'generated_at': snapshot.generatedAt.toIso8601String(),
        'signals': snapshot.signals,
      }),
    );
  }

  Future<void> persistAlerts(List<ReleaseAlert> alerts) async {
    final dir = await _dir();
    final file = File(
      '${dir.path}/alerts_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(
      jsonEncode(
        alerts
            .map(
              (a) => {
                'id': a.id,
                'severity': a.severity.name,
                'metric': a.metric,
                'threshold': a.threshold,
                'value': a.value,
                'owner': a.owner,
                'acknowledged_at': a.acknowledgedAt?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
  }

  Future<void> persistStableReport(ReleaseStableReport report) async {
    final dir = await _dir();
    final file = File('${dir.path}/stable_${report.id}.json');
    await file.writeAsString(
      jsonEncode({
        'id': report.id,
        'decision': report.decision,
        'summary': report.summary,
        'generated_at': report.generatedAt.toIso8601String(),
      }),
    );
  }

  Future<Directory> _dir() async {
    final dir = Directory('reports/release/operations');
    await dir.create(recursive: true);
    return dir;
  }
}
