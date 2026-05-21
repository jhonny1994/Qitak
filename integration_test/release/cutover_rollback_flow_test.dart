import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/cutover_service.dart';
import 'package:qitak_app/features/release/domain/rollback_verification_service.dart';

void main() {
  test('cutover then verification flow emits valid states', () {
    final cutover = CutoverService().run(prechecksPass: true);
    final report = RollbackVerificationService().verify(rollbackRunId: 'rb1');
    expect(cutover.id, isNotEmpty);
    expect(report.result, isTrue);
  });
}
