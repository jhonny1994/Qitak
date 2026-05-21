import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/data/release_decision_record_codec.dart';
import 'package:qitak_app/features/release/data/release_decision_record_repository.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

void main() {
  test('persists and restores decision record payload', () async {
    final codec = ReleaseDecisionRecordCodec();
    final repository = ReleaseDecisionRecordRepository(codec);
    final tempDir = await Directory.systemTemp.createTemp(
      'release_record_test',
    );
    final record = ReleaseDecisionRecord(
      runId: 'run-1',
      publishedAt: DateTime.utc(2026, 5, 12),
      decision: ReleaseDecision.ready,
      summary: 'ok',
      evidenceIndex: const [
        {'gate': 'analyze', 'ref': 'reports/release/a.txt'},
      ],
    );

    final file = await repository.persist(
      record: record,
      directory: tempDir.path,
    );
    final decoded = codec.decode(await file.readAsString());
    expect(decoded.runId, 'run-1');
    expect(decoded.decision, ReleaseDecision.ready);
    expect(decoded.evidenceIndex.single['gate'], 'analyze');
  });
}
