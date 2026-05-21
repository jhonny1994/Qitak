import 'package:flutter/material.dart';
import 'package:qitak_app/core/l10n/release_readiness_labels.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class ReleaseBlockerSections extends StatelessWidget {
  const ReleaseBlockerSections({required this.blockers, super.key});

  final List<ReleaseBlocker> blockers;

  @override
  Widget build(BuildContext context) {
    if (blockers.isEmpty) return const SizedBox.shrink();
    final grouped = <ReleaseBlockerArea, List<ReleaseBlocker>>{};
    for (final blocker in blockers) {
      grouped.putIfAbsent(blocker.area, () => <ReleaseBlocker>[]).add(blocker);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: QitakPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.blockerAreaLabel(entry.key),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final blocker in entry.value)
                  QitakQueueRow(
                    title: blocker.gateName,
                    meta:
                        '${context.blockerSeverityLabel(blocker.severity)} | ${blocker.owner} | ${blocker.remediation}',
                    status: context.blockerSeverityLabel(blocker.severity),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
