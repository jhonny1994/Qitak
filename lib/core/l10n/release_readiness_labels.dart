import 'package:flutter/widgets.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

extension ReleaseReadinessLabels on BuildContext {
  String blockerSeverityLabel(ReleaseBlockerSeverity severity) {
    switch (severity) {
      case ReleaseBlockerSeverity.critical:
        return l10n.releaseSeverityCritical;
      case ReleaseBlockerSeverity.high:
        return l10n.releaseSeverityHigh;
      case ReleaseBlockerSeverity.medium:
        return l10n.releaseSeverityMedium;
    }
  }

  String blockerAreaLabel(ReleaseBlockerArea area) {
    switch (area) {
      case ReleaseBlockerArea.auth:
        return l10n.releaseAreaAuth;
      case ReleaseBlockerArea.transactions:
        return l10n.releaseAreaTransactions;
      case ReleaseBlockerArea.localization:
        return l10n.releaseAreaLocalization;
      case ReleaseBlockerArea.quality:
        return l10n.releaseAreaQuality;
      case ReleaseBlockerArea.operations:
        return l10n.releaseAreaOperations;
    }
  }
}
