import 'package:flutter/widgets.dart';

import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/features/support/presentation/support_ticket_create_sheet.dart';

String supportReasonLabelForCode(
  BuildContext context,
  String reasonCode,
  List<AppPolicyOption> options,
) {
  final match = options.where((option) => option.code == reasonCode).firstOrNull;
  if (match == null) {
    return reasonCode;
  }
  return supportReasonLabel(context, match.labelKey);
}
