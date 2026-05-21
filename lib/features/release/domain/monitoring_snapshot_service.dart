import 'package:qitak_app/features/release/domain/launch_operations_models.dart';

class MonitoringSnapshotService {
  MonitoringSnapshot build({
    required String releaseRunId,
    required Map<String, SignalStatus> signals,
  }) {
    const required = <String>{
      'auth',
      'transactions',
      'messaging',
      'release_gates',
    };
    final completeSignals = <String, SignalStatus>{...signals};
    for (final key in required) {
      completeSignals.putIfAbsent(key, () => SignalStatus.unknown);
    }
    final now = DateTime.now().toUtc();
    return MonitoringSnapshot(
      id: 'snap-${now.millisecondsSinceEpoch}',
      generatedAt: now,
      releaseRunId: releaseRunId,
      signals: completeSignals,
    );
  }
}
