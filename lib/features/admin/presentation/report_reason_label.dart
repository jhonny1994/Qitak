import 'package:flutter/widgets.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/features/admin/domain/admin_report.dart';
import 'package:qitak_app/features/support/presentation/support_reason_label.dart';

String adminReportReasonLabel(
  BuildContext context,
  AdminReport report, {
  List<AppPolicyOption> supportReasonOptions = const <AppPolicyOption>[],
}) {
  if (report.entityType == 'support') {
    return supportReasonLabelForCode(
      context,
      report.reason,
      supportReasonOptions,
    );
  }

  if (report.entityType == 'listing') {
    switch (report.reason) {
      case 'spam':
        return context.l10n.reportListingReasonSpam;
      case 'misleading':
        return context.l10n.reportListingReasonMisleading;
      case 'wrong_category':
        return context.l10n.reportListingReasonWrongCategory;
      case 'other':
        return context.l10n.reportListingReasonOther;
    }
  }

  return report.reason;
}
