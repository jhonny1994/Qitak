import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/release_blocker_mapper.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

void main() {
  test('maps failures to blockers', () {
    final mapper = ReleaseBlockerMapper();
    final blockers = mapper.fromGateResults([
      ReleaseGateResult(
        gateName: 'supabase test db',
        status: ReleaseGateStatus.fail,
        evidenceRef: 'ref',
        checkedAt: DateTime.utc(2026, 5, 12),
        owner: 'backend',
      ),
    ]);
    expect(blockers, hasLength(1));
    expect(blockers.first.area, ReleaseBlockerArea.transactions);
    expect(blockers.first.severity, ReleaseBlockerSeverity.critical);
  });
}
