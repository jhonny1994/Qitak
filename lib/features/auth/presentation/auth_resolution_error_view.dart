import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/providers/auth_resolution_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class AuthResolutionErrorView extends ConsumerWidget {
  const AuthResolutionErrorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return QitakStateMessage(
      title: context.l10n.errorStateTitle,
      message: context.l10n.authResolutionError,
      action: FilledButton(
        onPressed: () => ref.read(authResolutionProvider.notifier).resolve(),
        child: Text(context.l10n.retryAction),
      ),
    );
  }
}
