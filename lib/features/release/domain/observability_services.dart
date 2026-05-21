import 'package:qitak_app/features/release/domain/observability_models.dart';

class ReleaseHealthService {
  ReleaseHealthSnapshot snapshot() {
    final now = DateTime.now().toUtc();
    return ReleaseHealthSnapshot(
      id: 'hs-${now.millisecondsSinceEpoch}',
      generatedAt: now,
      signals: const {
        'auth_success_rate': 0.99,
        'transaction_success_rate': 0.98,
        'message_delivery_rate': 0.995,
      },
    );
  }
}

class ReleaseAlertService {
  List<ReleaseAlert> evaluate(ReleaseHealthSnapshot snapshot) {
    final alerts = <ReleaseAlert>[];
    void check(String metric, double threshold, AlertSeverity severity) {
      final value = snapshot.signals[metric] ?? 0;
      if (value < threshold) {
        alerts.add(
          ReleaseAlert(
            id: 'al-${snapshot.id}-$metric',
            severity: severity,
            metric: metric,
            threshold: threshold,
            value: value,
            owner: 'ops-oncall',
          ),
        );
      }
    }

    check('auth_success_rate', 0.97, AlertSeverity.high);
    check('transaction_success_rate', 0.97, AlertSeverity.critical);
    check('message_delivery_rate', 0.99, AlertSeverity.medium);
    return alerts;
  }

  ReleaseAlert acknowledge(ReleaseAlert alert, DateTime when) {
    return ReleaseAlert(
      id: alert.id,
      severity: alert.severity,
      metric: alert.metric,
      threshold: alert.threshold,
      value: alert.value,
      owner: alert.owner,
      acknowledgedAt: when,
    );
  }
}
