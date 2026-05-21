import 'package:flutter/material.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class LegalInformationScreen extends StatelessWidget {
  const LegalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: qitakPagePadding,
      children: [
        QitakPanel(
          child: QitakSectionHeader(
            eyebrow: context.l10n.legalInformationEyebrow,
            title: context.l10n.legalInformationTitle,
            subtitle: context.l10n.legalInformationSubtitle,
          ),
        ),
        const SizedBox(height: 18),
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakQueueRow(
                title: context.l10n.legalInformationTermsTitle,
                meta: context.l10n.legalInformationTermsBody,
                status: context.l10n.legalInformationStatus,
              ),
              QitakQueueRow(
                title: context.l10n.legalInformationPrivacyTitle,
                meta: context.l10n.legalInformationPrivacyBody,
                status: context.l10n.legalInformationStatus,
              ),
              QitakQueueRow(
                title: context.l10n.legalInformationMarketplaceTitle,
                meta: context.l10n.legalInformationMarketplaceBody,
                status: context.l10n.legalInformationMarketplaceStatus,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
