import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/cutover_rollback_models.dart';
import 'package:qitak_app/features/release/domain/cutover_service.dart';
import 'package:qitak_app/features/release/domain/rollback_service.dart';

void main() {
  test('cutover returns completed when prechecks pass', () {
    final run = CutoverService().run(prechecksPass: true);
    expect(run.status, OperationStatus.cutoverCompleted);
  });

  test('rollback returns completed with reason', () {
    final run = RollbackService().trigger(
      severity: RollbackSeverity.critical,
      owner: 'ops',
      reason: 'fail',
    );
    expect(run.status, OperationStatus.rollbackCompleted);
    expect(run.reason, 'fail');
  });
}
