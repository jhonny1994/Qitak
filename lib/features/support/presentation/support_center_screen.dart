import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/l10n/app_error_localization.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/support/data/support_repository.dart';
import 'package:qitak_app/features/support/domain/support_ticket.dart';
import 'package:qitak_app/features/support/presentation/support_reason_label.dart';
import 'package:qitak_app/features/support/presentation/support_ticket_create_sheet.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';
import 'package:qitak_app/shared/widgets/qitak_error_state.dart';

final supportTicketsProvider = FutureProvider<List<SupportTicket>>((ref) {
  return ref.watch(supportRepositoryProvider).listTickets();
});

class SupportCenterScreen extends ConsumerWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final profile = session.profile;
    final ticketsAsync = ref.watch(supportTicketsProvider);
    final supportReasonOptions =
        ref.watch(supportReasonOptionsProvider).asData?.value ??
        const <AppPolicyOption>[];

    if (profile == null) {
      return QitakStateMessage(
        title: context.l10n.authGateTitle,
        message: context.l10n.authGateBody,
      );
    }

    return QitakPullToRefresh(
      onRefresh: () async {
        ref.invalidate(supportTicketsProvider);
        await ref.read(supportTicketsProvider.future);
      },
      slivers: [
        SliverPadding(
          padding: qitakPagePadding,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              QitakPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QitakSectionHeader(
                      eyebrow: context.l10n.supportCenterEyebrow,
                      title: context.l10n.supportCenterTitle,
                      subtitle: context.l10n.supportCenterSubtitle,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const Key('support-create-ticket-button'),
                      onPressed: () => _openCreateTicketSheet(context, ref),
                      child: Text(context.l10n.supportCenterCreateAction),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              QitakPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.supportCenterRoutingTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => context.go(_dealGuidancePath(profile.role)),
                      borderRadius: BorderRadius.circular(18),
                      child: QitakQueueRow(
                        title: context.l10n.supportCenterRoutingDisputeTitle,
                        meta: context.l10n.supportCenterRoutingDisputeBody,
                        status: _dealGuidanceStatus(context, profile.role),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          context.go(_profileSettingsPath(profile.role)),
                      borderRadius: BorderRadius.circular(18),
                      child: QitakQueueRow(
                        title: context.l10n.supportCenterRoutingAccountTitle,
                        meta: context.l10n.supportCenterRoutingAccountBody,
                        status: context.l10n.accountSettingsTitle,
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                    QitakQueueRow(
                      title: context.l10n.supportCenterRoutingScopeTitle,
                      meta: context.l10n.supportCenterRoutingScopeBody,
                      status: context.l10n.supportCenterEyebrow,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              QitakPanel(
                child: ticketsAsync.when(
                  data: (tickets) => tickets.isEmpty
                      ? QitakStateMessage(
                          title: context.l10n.supportCenterEmptyTitle,
                          message: context.l10n.supportCenterEmptyBody,
                          icon: Icons.support_agent_rounded,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.supportCenterTicketListTitle,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            for (final ticket in tickets)
                              QitakQueueRow(
                                title: supportReasonLabelForCode(
                                  context,
                                  ticket.reason,
                                  supportReasonOptions,
                                ),
                                meta: ticket.description,
                                status: supportTicketStatusLabel(
                                  context,
                                  ticket.status,
                                ),
                              ),
                          ],
                        ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, _) => QitakErrorState(
                    message: error is AppException
                        ? context.appExceptionMessage(error)
                        : error.toString(),
                    onRetry: () => ref.invalidate(supportTicketsProvider),
                    retryLabel: context.l10n.retryAction,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _openCreateTicketSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final created = await showSupportTicketCreateSheet(context);
    if (created != true || !context.mounted) {
      return;
    }
    ref.invalidate(supportTicketsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.supportTicketCreated)),
    );
  }
}

String _profileSettingsPath(AccountRole role) {
  switch (role) {
    case AccountRole.admin:
    case AccountRole.superAdmin:
      return '/admin/profile/settings';
    case AccountRole.seller:
    case AccountRole.buyer:
    case AccountRole.anonymous:
      return '/profile/settings';
  }
}

String _dealGuidancePath(AccountRole role) {
  switch (role) {
    case AccountRole.admin:
    case AccountRole.superAdmin:
      return '/admin/disputes';
    case AccountRole.seller:
    case AccountRole.buyer:
    case AccountRole.anonymous:
      return '/transactions';
  }
}

String _dealGuidanceStatus(BuildContext context, AccountRole role) {
  switch (role) {
    case AccountRole.admin:
    case AccountRole.superAdmin:
      return context.l10n.adminQueuesTitle;
    case AccountRole.seller:
    case AccountRole.buyer:
    case AccountRole.anonymous:
      return context.l10n.disputeTitle;
  }
}
