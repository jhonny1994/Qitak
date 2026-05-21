import 'package:flutter/material.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class QitakErrorState extends StatelessWidget {
  const QitakErrorState({
    required this.message,
    super.key,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return QitakStateMessage(
      icon: Icons.error_outline_rounded,
      title: context.l10n.errorStateTitle,
      message: message,
      action: onRetry == null
          ? null
          : FilledButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
    );
  }
}
