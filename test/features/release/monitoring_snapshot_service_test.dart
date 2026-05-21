import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/launch_operations_models.dart';
import 'package:qitak_app/features/release/domain/monitoring_snapshot_service.dart';

void main() {
  test('injects required signals when missing', () {
    final service = MonitoringSnapshotService();
    final snapshot = service.build(
      releaseRunId: 'run-1',
      signals: const {'auth': SignalStatus.pass},
    );
    expect(snapshot.signals.containsKey('transactions'), isTrue);
    expect(snapshot.signals.containsKey('messaging'), isTrue);
    expect(snapshot.signals.containsKey('release_gates'), isTrue);
  });
}
