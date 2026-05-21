import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

class ReleaseReadinessSummaryVm {
  const ReleaseReadinessSummaryVm({
    required this.title,
    required this.decisionText,
    required this.blockerCount,
  });

  final String title;
  final String decisionText;
  final int blockerCount;
}

ReleaseReadinessSummaryVm buildReleaseReadinessSummary({
  required ReleaseReadinessRun? run,
  required String title,
  required String readyLabel,
  required String notReadyLabel,
}) {
  if (run == null) {
    return ReleaseReadinessSummaryVm(
      title: title,
      decisionText: notReadyLabel,
      blockerCount: 0,
    );
  }
  return ReleaseReadinessSummaryVm(
    title: title,
    decisionText: run.result == ReleaseDecision.ready
        ? readyLabel
        : notReadyLabel,
    blockerCount: run.blockers.where((it) => !it.resolved).length,
  );
}
