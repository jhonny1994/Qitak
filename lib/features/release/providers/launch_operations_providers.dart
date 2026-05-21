import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/features/release/data/launch_operations_repository.dart';
import 'package:qitak_app/features/release/domain/launch_checklist_service.dart';
import 'package:qitak_app/features/release/domain/launch_incident_service.dart';
import 'package:qitak_app/features/release/domain/launch_operations_models.dart';
import 'package:qitak_app/features/release/domain/monitoring_snapshot_service.dart';
import 'package:qitak_app/features/release/domain/run_launch_checklist.dart';

final launchOperationsRepositoryProvider = Provider<LaunchOperationsRepository>(
  (ref) => LaunchOperationsRepository(),
);
final launchChecklistServiceProvider = Provider<LaunchChecklistService>(
  (ref) => LaunchChecklistService(),
);
final monitoringSnapshotServiceProvider = Provider<MonitoringSnapshotService>(
  (ref) => MonitoringSnapshotService(),
);
final launchIncidentServiceProvider = Provider<LaunchIncidentService>(
  (ref) => LaunchIncidentService(),
);
final runLaunchChecklistProvider = Provider<RunLaunchChecklist>(
  (ref) => RunLaunchChecklist(ref.watch(launchChecklistServiceProvider)),
);

class LaunchOperationsState {
  const LaunchOperationsState({
    this.checklistRun,
    this.snapshot,
    this.incident,
    this.running = false,
  });

  final LaunchChecklistRun? checklistRun;
  final MonitoringSnapshot? snapshot;
  final LaunchIncident? incident;
  final bool running;

  LaunchOperationsState copyWith({
    LaunchChecklistRun? checklistRun,
    MonitoringSnapshot? snapshot,
    LaunchIncident? incident,
    bool? running,
  }) {
    return LaunchOperationsState(
      checklistRun: checklistRun ?? this.checklistRun,
      snapshot: snapshot ?? this.snapshot,
      incident: incident ?? this.incident,
      running: running ?? this.running,
    );
  }
}

class LaunchOperationsNotifier extends Notifier<LaunchOperationsState> {
  @override
  LaunchOperationsState build() => const LaunchOperationsState();

  Future<void> executeChecklist() async {
    state = state.copyWith(running: true);
    final prerequisites = <ChecklistPrerequisite>[
      const ChecklistPrerequisite(
        name: 'flutter_analyze',
        status: SignalStatus.unknown,
        owner: 'mobile',
        evidenceRef: 'manual verification required',
      ),
      const ChecklistPrerequisite(
        name: 'flutter_test',
        status: SignalStatus.unknown,
        owner: 'mobile',
        evidenceRef: 'manual verification required',
      ),
      const ChecklistPrerequisite(
        name: 'integration_test',
        status: SignalStatus.unknown,
        owner: 'qa',
        evidenceRef: 'manual verification required',
      ),
      const ChecklistPrerequisite(
        name: 'supabase_test_db',
        status: SignalStatus.unknown,
        owner: 'backend',
        evidenceRef: 'manual verification required',
      ),
    ];
    final run = ref.read(runLaunchChecklistProvider).call(prerequisites);
    await ref.read(launchOperationsRepositoryProvider).writeChecklist(run);
    final snapshot = ref
        .read(monitoringSnapshotServiceProvider)
        .build(
          releaseRunId: run.id,
          signals: const {
            'auth': SignalStatus.unknown,
            'transactions': SignalStatus.unknown,
            'messaging': SignalStatus.unknown,
            'release_gates': SignalStatus.unknown,
          },
        );
    await ref.read(launchOperationsRepositoryProvider).writeSnapshot(snapshot);
    state = state.copyWith(
      checklistRun: run,
      snapshot: snapshot,
      running: false,
    );
  }

  Future<void> raiseIncident({
    required IncidentSeverity severity,
    required String owner,
    required String action,
  }) async {
    final incident = ref
        .read(launchIncidentServiceProvider)
        .build(
          severity: severity,
          owner: owner,
          action: action,
        );
    await ref.read(launchOperationsRepositoryProvider).writeIncident(incident);
    state = state.copyWith(incident: incident);
  }
}

final launchOperationsProvider =
    NotifierProvider<LaunchOperationsNotifier, LaunchOperationsState>(
      LaunchOperationsNotifier.new,
    );
