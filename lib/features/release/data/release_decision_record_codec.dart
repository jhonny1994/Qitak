import 'dart:convert';

import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

class ReleaseDecisionRecordCodec {
  String encode(ReleaseDecisionRecord record) {
    return jsonEncode({
      'run_id': record.runId,
      'published_at': record.publishedAt.toIso8601String(),
      'decision': record.decision.name,
      'summary': record.summary,
      'evidence_index': record.evidenceIndex,
    });
  }

  ReleaseDecisionRecord decode(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return ReleaseDecisionRecord(
      runId: map['run_id'] as String,
      publishedAt: DateTime.parse(map['published_at'] as String),
      decision: (map['decision'] as String) == ReleaseDecision.ready.name
          ? ReleaseDecision.ready
          : ReleaseDecision.notReady,
      summary: map['summary'] as String,
      evidenceIndex: (map['evidence_index'] as List<dynamic>)
          .map((item) => Map<String, String>.from(item as Map))
          .toList(),
    );
  }
}
