import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/features/release/data/release_evidence_repository.dart';
import 'package:qitak_app/features/release/data/release_gate_runner.dart';
import 'package:qitak_app/features/release/domain/release_blocker_mapper.dart';
import 'package:qitak_app/features/release/domain/release_decision_service.dart';
import 'package:qitak_app/features/release/domain/release_gate_validation.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';
import 'package:qitak_app/features/release/domain/run_release_readiness.dart';

final releaseEvidenceRepositoryProvider = Provider<ReleaseEvidenceRepository>(
  (ref) => ReleaseEvidenceRepository(),
);

final releaseGateRunnerProvider = Provider<ReleaseGateRunnerImpl>(
  (ref) => ReleaseGateRunnerImpl(ref.watch(releaseEvidenceRepositoryProvider)),
);

final releaseDecisionServiceProvider = Provider<ReleaseDecisionService>(
  (ref) => ReleaseDecisionService(ReleaseGateValidation()),
);

final releaseBlockerMapperProvider = Provider<ReleaseBlockerMapper>(
  (ref) => ReleaseBlockerMapper(),
);

final runReleaseReadinessProvider = Provider<RunReleaseReadiness>(
  (ref) => RunReleaseReadiness(
    gateRunner: ref.watch(releaseGateRunnerProvider),
    decisionService: ref.watch(releaseDecisionServiceProvider),
    blockerMapper: ref.watch(releaseBlockerMapperProvider),
  ),
);

class ReleaseReadinessState {
  const ReleaseReadinessState({this.run, this.running = false});

  final ReleaseReadinessRun? run;
  final bool running;

  ReleaseReadinessState copyWith({ReleaseReadinessRun? run, bool? running}) {
    return ReleaseReadinessState(
      run: run ?? this.run,
      running: running ?? this.running,
    );
  }
}

class ReleaseReadinessNotifier extends Notifier<ReleaseReadinessState> {
  @override
  ReleaseReadinessState build() => const ReleaseReadinessState();

  Future<void> execute({required String initiatedBy}) async {
    state = state.copyWith(running: true);
    final run = await ref
        .read(runReleaseReadinessProvider)
        .call(initiatedBy: initiatedBy);
    state = state.copyWith(run: run, running: false);
  }
}

final releaseReadinessProvider =
    NotifierProvider<ReleaseReadinessNotifier, ReleaseReadinessState>(
      ReleaseReadinessNotifier.new,
    );
