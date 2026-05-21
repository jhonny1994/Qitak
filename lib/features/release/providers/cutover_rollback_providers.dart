import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/features/release/data/cutover_rollback_repository.dart';
import 'package:qitak_app/features/release/domain/cutover_rollback_models.dart';
import 'package:qitak_app/features/release/domain/cutover_service.dart';
import 'package:qitak_app/features/release/domain/rollback_service.dart';
import 'package:qitak_app/features/release/domain/rollback_verification_service.dart';

final cutoverServiceProvider = Provider<CutoverService>(
  (ref) => CutoverService(),
);
final rollbackServiceProvider = Provider<RollbackService>(
  (ref) => RollbackService(),
);
final rollbackVerificationServiceProvider =
    Provider<RollbackVerificationService>(
      (ref) => RollbackVerificationService(),
    );
final cutoverRollbackRepositoryProvider = Provider<CutoverRollbackRepository>(
  (ref) => CutoverRollbackRepository(),
);

class CutoverRollbackState {
  const CutoverRollbackState({
    this.cutoverRun,
    this.rollbackRun,
    this.verificationReport,
  });
  final CutoverRun? cutoverRun;
  final RollbackRun? rollbackRun;
  final RollbackVerificationReport? verificationReport;

  CutoverRollbackState copyWith({
    CutoverRun? cutoverRun,
    RollbackRun? rollbackRun,
    RollbackVerificationReport? verificationReport,
  }) {
    return CutoverRollbackState(
      cutoverRun: cutoverRun ?? this.cutoverRun,
      rollbackRun: rollbackRun ?? this.rollbackRun,
      verificationReport: verificationReport ?? this.verificationReport,
    );
  }
}

class CutoverRollbackNotifier extends Notifier<CutoverRollbackState> {
  @override
  CutoverRollbackState build() => const CutoverRollbackState();

  Future<void> runCutover({required bool prechecksPass}) async {
    final run = ref
        .read(cutoverServiceProvider)
        .run(prechecksPass: prechecksPass);
    await ref.read(cutoverRollbackRepositoryProvider).persistCutover(run);
    state = state.copyWith(cutoverRun: run);
  }

  Future<void> triggerRollback() async {
    final rollback = ref
        .read(rollbackServiceProvider)
        .trigger(
          severity: RollbackSeverity.critical,
          owner: 'ops-oncall',
          reason: 'Critical post-cutover failure detected.',
        );
    await ref.read(cutoverRollbackRepositoryProvider).persistRollback(rollback);
    final report = ref
        .read(rollbackVerificationServiceProvider)
        .verify(rollbackRunId: rollback.id);
    await ref
        .read(cutoverRollbackRepositoryProvider)
        .persistVerification(report);
    state = state.copyWith(rollbackRun: rollback, verificationReport: report);
  }
}

final cutoverRollbackProvider =
    NotifierProvider<CutoverRollbackNotifier, CutoverRollbackState>(
      CutoverRollbackNotifier.new,
    );
