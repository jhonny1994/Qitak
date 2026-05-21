import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';
import 'package:qitak_app/shared/widgets/qitak_error_state.dart';

// ignore: specify_nonobvious_property_types, Riverpod family typedefs vary in this repo setup.
final transactionHistoryProvider =
    FutureProvider.autoDispose<List<_TransactionHistoryItem>>((ref) async {
      final userId = ref.watch(authSessionProvider).profile?.id;
      if (userId == null) {
        return const <_TransactionHistoryItem>[];
      }

      final repository = ref.read(transactionRepositoryProvider);
      final transactions = await repository.listForUser(userId);
      if (transactions.isEmpty) {
        return const <_TransactionHistoryItem>[];
      }

      final client = ref.read(supabaseClientProvider);
      if (client == null) {
        return transactions
            .map((item) => _TransactionHistoryItem.fallback(item, userId))
            .toList(growable: false);
      }

      final listingIds = transactions
          .map((item) => item.listingId)
          .toSet()
          .toList(growable: false);
      final partnerIds = transactions
          .map(
            (item) => item.buyerUserId == userId
                ? item.sellerUserId
                : item.buyerUserId,
          )
          .toSet()
          .toList(growable: false);

      final listingsFuture = client
          .from('listings')
          .select('id,title')
          .inFilter('id', listingIds);
      final profilesFuture = client
          .from('profiles')
          .select('id,full_name')
          .inFilter('id', partnerIds);

      final results = await Future.wait<Object>([
        listingsFuture,
        profilesFuture,
      ]);
      final listingRows = results[0] as List<dynamic>;
      final profileRows = results[1] as List<dynamic>;
      final listingTitles = <String, String>{
        for (final row in listingRows.whereType<Map<String, dynamic>>())
          row['id'] as String: row['title'] as String? ?? row['id'] as String,
      };
      final partnerNames = <String, String>{
        for (final row in profileRows.whereType<Map<String, dynamic>>())
          row['id'] as String:
              (row['full_name'] as String?)?.trim().isNotEmpty == true
              ? (row['full_name'] as String).trim()
              : row['id'] as String,
      };

      return transactions
          .map(
            (item) => _TransactionHistoryItem(
              transaction: item,
              listingTitle: listingTitles[item.listingId] ?? item.listingId,
              partnerName:
                  partnerNames[item.buyerUserId == userId
                      ? item.sellerUserId
                      : item.buyerUserId] ??
                  (item.buyerUserId == userId
                      ? item.sellerUserId
                      : item.buyerUserId),
            ),
          )
          .toList(growable: false);
    });

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(transactionHistoryProvider);

    return history.when(
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: qitakPagePadding,
            child: QitakStateMessage(
              title: context.l10n.transactionHistoryTitle,
              message: context.l10n.transactionHistoryEmpty,
              action: FilledButton(
                onPressed: () => context.go('/home'),
                child: Text(context.l10n.messagesBrowseListingsAction),
              ),
            ),
          );
        }

        return QitakPullToRefresh(
          onRefresh: () => ref.refresh(transactionHistoryProvider.future),
          child: ListView(
            padding: qitakPagePadding,
            children: [
              QitakPanel(
                child: QitakSectionHeader(
                  eyebrow: context.l10n.transactionHistoryTitle,
                  title: context.l10n.transactionHistoryTitle,
                  subtitle: context.l10n.transactionsTitle,
                ),
              ),
              const SizedBox(height: 18),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.go('/deals/${item.transaction.id}'),
                    child: QitakPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QitakSignalStrip(
                            label: item.partnerName,
                            value: item.listingTitle,
                            status: context.l10n.displayTransactionState(
                              item.transaction.state,
                            ),
                          ),
                          const SizedBox(height: 12),
                          QitakDetailRow(
                            label: context.l10n.transactionRecordLabel,
                            value: context.l10n.transactionReferenceLabel(
                              item.transaction.id,
                            ),
                          ),
                          QitakDetailRow(
                            label: context.l10n.listingSellerSectionTitle,
                            value: item.partnerName,
                          ),
                          QitakDetailRow(
                            label: context.l10n.notificationsTitle,
                            value: _formatDate(item.transaction.updatedAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => Padding(
        padding: qitakPagePadding,
        child: QitakErrorState(
          message: error.toString(),
          onRetry: () => ref.refresh(transactionHistoryProvider),
        ),
      ),
      loading: () => ListView(
        padding: qitakPagePadding,
        children: const [
          QitakPanel(child: QitakSkeletonBox(height: 96)),
          SizedBox(height: 12),
          QitakPanel(child: QitakSkeletonBox(height: 96)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _TransactionHistoryItem {
  const _TransactionHistoryItem({
    required this.transaction,
    required this.listingTitle,
    required this.partnerName,
  });

  factory _TransactionHistoryItem.fallback(
    TransactionRecord transaction,
    String currentUserId,
  ) {
    return _TransactionHistoryItem(
      transaction: transaction,
      listingTitle: transaction.listingId,
      partnerName: transaction.buyerUserId == currentUserId
          ? transaction.sellerUserId
          : transaction.buyerUserId,
    );
  }

  final TransactionRecord transaction;
  final String listingTitle;
  final String partnerName;
}
