import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/features/release/data/observability_repository.dart';
import 'package:qitak_app/features/release/domain/observability_models.dart';
import 'package:qitak_app/features/release/domain/observability_services.dart';

final releaseHealthServiceProvider = Provider<ReleaseHealthService>(
  (ref) => ReleaseHealthService(),
);
final releaseAlertServiceProvider = Provider<ReleaseAlertService>(
  (ref) => ReleaseAlertService(),
);
final observabilityRepositoryProvider = Provider<ObservabilityRepository>(
  (ref) => ObservabilityRepository(),
);

class ReleaseObservabilityState {
  const ReleaseObservabilityState({
    this.snapshot,
    this.alerts = const <ReleaseAlert>[],
  });
  final ReleaseHealthSnapshot? snapshot;
  final List<ReleaseAlert> alerts;

  ReleaseObservabilityState copyWith({
    ReleaseHealthSnapshot? snapshot,
    List<ReleaseAlert>? alerts,
  }) {
    return ReleaseObservabilityState(
      snapshot: snapshot ?? this.snapshot,
      alerts: alerts ?? this.alerts,
    );
  }
}

class ReleaseObservabilityNotifier extends Notifier<ReleaseObservabilityState> {
  @override
  ReleaseObservabilityState build() => const ReleaseObservabilityState();

  Future<void> refresh() async {
    final snapshot = ref.read(releaseHealthServiceProvider).snapshot();
    final alerts = ref.read(releaseAlertServiceProvider).evaluate(snapshot);
    await ref.read(observabilityRepositoryProvider).persistSnapshot(snapshot);
    await ref.read(observabilityRepositoryProvider).persistAlerts(alerts);
    state = state.copyWith(snapshot: snapshot, alerts: alerts);
  }

  Future<void> acknowledgeFirstAlert() async {
    if (state.alerts.isEmpty) return;
    final first = state.alerts.first;
    final acked = ref
        .read(releaseAlertServiceProvider)
        .acknowledge(first, DateTime.now().toUtc());
    final updated = [acked, ...state.alerts.skip(1)];
    await ref.read(observabilityRepositoryProvider).persistAlerts(updated);
    state = state.copyWith(alerts: updated);
  }

  Future<void> exportStableReport() async {
    final now = DateTime.now().toUtc();
    final report = ReleaseStableReport(
      id: 'stable-${now.millisecondsSinceEpoch}',
      decision: state.alerts.any((a) => a.severity == AlertSeverity.critical)
          ? 'hold'
          : 'stable',
      summary: 'Release observability exit status.',
      generatedAt: now,
    );
    await ref.read(observabilityRepositoryProvider).persistStableReport(report);
  }
}

final releaseObservabilityProvider =
    NotifierProvider<ReleaseObservabilityNotifier, ReleaseObservabilityState>(
      ReleaseObservabilityNotifier.new,
    );
