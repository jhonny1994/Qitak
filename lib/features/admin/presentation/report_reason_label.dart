import 'package:flutter/widgets.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/admin/domain/admin_report.dart';

String adminReportReasonLabel(BuildContext context, AdminReport report) {
  if (report.entityType == 'support') {
    switch (report.reason) {
      case 'account_access':
        return context.l10n.supportReasonAccountAccess;
      case 'payment_issue':
        return context.l10n.supportReasonPaymentIssue;
      case 'seller_issue':
        return context.l10n.supportReasonSellerIssue;
      case 'technical_issue':
        return context.l10n.supportReasonTechnicalIssue;
      case 'other':
        return context.l10n.supportReasonOther;
    }
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
