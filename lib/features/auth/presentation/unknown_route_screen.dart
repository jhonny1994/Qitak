import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({required this.requestedPath, super.key});

  final String requestedPath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: qitakPagePadding,
      child: QitakStateMessage(
        title: context.l10n.unknownRouteTitle,
        message: '${context.l10n.unknownRouteBody}\n$requestedPath',
        action: FilledButton(
          onPressed: () => context.go('/home'),
          child: Text(context.l10n.unknownRouteGoHome),
        ),
      ),
    );
  }
}
