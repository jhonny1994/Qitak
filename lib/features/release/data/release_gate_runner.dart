import 'dart:async';

import 'package:qitak_app/features/release/data/release_evidence_repository.dart';
import 'package:qitak_app/features/release/domain/release_readiness_contract.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

class ReleaseGateRunnerImpl implements ReleaseGateRunner {
  ReleaseGateRunnerImpl(this.evidenceRepository);

  final ReleaseEvidenceRepository evidenceRepository;

  static const _defaultGates = <({String name, String owner})>[
    (name: 'flutter analyze --fatal-infos', owner: 'mobile'),
    (name: 'flutter test', owner: 'mobile'),
    (name: 'flutter test integration_test', owner: 'qa'),
    (name: 'supabase test db', owner: 'backend'),
  ];

  @override
  Future<List<ReleaseGateResult>> runAll() async {
    final now = DateTime.now().toUtc();
    return _defaultGates
        .map(
          (gate) => ReleaseGateResult(
            gateName: gate.name,
            status: ReleaseGateStatus.missing,
            evidenceRef:
                'Manual verification required. No authoritative runtime execution for "${gate.name}". Expected evidence path: '
                '${evidenceRepository.buildRef(gate.name, now)}',
            checkedAt: now,
            owner: gate.owner,
          ),
        )
        .toList();
  }
}
