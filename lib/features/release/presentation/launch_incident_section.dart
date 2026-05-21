import 'package:flutter/material.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/release/domain/launch_operations_models.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class LaunchIncidentSection extends StatelessWidget {
  const LaunchIncidentSection({required this.incident, super.key});

  final LaunchIncident? incident;

  @override
  Widget build(BuildContext context) {
    if (incident == null) return const SizedBox.shrink();
    return QitakPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.releaseIncidentTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          QitakQueueRow(
            title: incident!.owner,
            meta: incident!.action,
            status: context.l10n.incidentSeverityText(incident!.severity),
          ),
        ],
      ),
    );
  }
}
