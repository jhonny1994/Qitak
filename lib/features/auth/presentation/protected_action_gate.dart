import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';
import 'package:qitak_app/features/auth/providers/redirect_intent_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

Future<void> showProtectedActionGate(
  BuildContext context,
  WidgetRef ref, {
  required PostAuthRedirectIntent intent,
}) async {
  ref.read(redirectIntentProvider.notifier).rememberedIntent = intent;
  final query = Uri(queryParameters: intent.toQueryParameters()).query;

  await showModalBottomSheet<void>(
    context: context,
    builder: (context) => ProtectedActionGateSheet(
      intent: intent,
      authQuery: query,
    ),
  );
}

class ProtectedActionGateSheet extends StatelessWidget {
  const ProtectedActionGateSheet({
    required this.intent,
    required this.authQuery,
    super.key,
  });

  final PostAuthRedirectIntent intent;
  final String authQuery;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: qitakPagePadding,
        child: QitakPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QitakSectionHeader(
                eyebrow: _eyebrow(context),
                title: _title(context),
                subtitle: _subtitle(context),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/auth/sign-in?$authQuery');
                },
                child: Text(context.l10n.signIn),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/auth/sign-up?$authQuery');
                },
                child: Text(context.l10n.createAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _eyebrow(BuildContext context) {
    switch (intent.targetValue) {
      case 'save-listing':
        return context.l10n.discoverySave;
      case 'message-seller':
        return context.l10n.discoveryMessageSeller;
      case 'start-transaction':
        return context.l10n.listingRequestToBuyAction;
      default:
        return context.l10n.authGateEyebrow;
    }
  }

  String _title(BuildContext context) {
    switch (intent.targetValue) {
      case 'save-listing':
        return context.l10n.authGateSaveTitle;
      case 'message-seller':
        return context.l10n.authGateMessageTitle;
      case 'start-transaction':
        return context.l10n.authGateBuyTitle;
      default:
        return context.l10n.authGateTitle;
    }
  }

  String _subtitle(BuildContext context) {
    switch (intent.targetValue) {
      case 'save-listing':
        return context.l10n.authGateSaveBody;
      case 'message-seller':
        return context.l10n.authGateMessageBody;
      case 'start-transaction':
        return context.l10n.authGateBuyBody;
      default:
        return context.l10n.authGateBody;
    }
  }
}
