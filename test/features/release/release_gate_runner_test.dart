import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/data/release_evidence_repository.dart';
import 'package:qitak_app/features/release/data/release_gate_runner.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

void main() {
  test(
    'runtime readiness gates stay missing until external evidence is verified',
    () async {
      final runner = ReleaseGateRunnerImpl(ReleaseEvidenceRepository());

      final results = await runner.runAll();

      expect(results, isNotEmpty);
      expect(
        results.every((gate) => gate.status == ReleaseGateStatus.missing),
        isTrue,
      );
      expect(
        results.every(
          (gate) => gate.evidenceRef.contains('Manual verification required.'),
        ),
        isTrue,
      );
      expect(
        results.map((gate) => gate.gateName),
        containsAll(<String>[
          'flutter analyze --fatal-infos',
          'flutter test',
          'flutter test integration_test',
          'supabase test db',
        ]),
      );
    },
  );
}
