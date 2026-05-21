import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';

class TransactionStateView {
  const TransactionStateView({
    this.items = const <TransactionRecord>[],
    this.lastError,
  });

  final List<TransactionRecord> items;
  final String? lastError;

  TransactionStateView copyWith({
    List<TransactionRecord>? items,
    String? lastError,
  }) {
    return TransactionStateView(
      items: items ?? this.items,
      lastError: lastError,
    );
  }
}

class TransactionNotifier extends Notifier<TransactionStateView> {
  @override
  TransactionStateView build() => const TransactionStateView();

  Future<void> refreshForUser(String userId) async {
    final items = await ref
        .read(transactionRepositoryProvider)
        .listForUser(userId);
    state = state.copyWith(items: items);
  }

  Future<bool> createIntent({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
    String dealType = 'buy',
    String? exchangeOffer,
  }) async {
    try {
      final record = await ref
          .read(transactionRepositoryProvider)
          .createIntent(
            listingId: listingId,
            buyerUserId: buyerUserId,
            sellerUserId: sellerUserId,
            dealType: dealType,
            exchangeOffer: exchangeOffer,
          );
      state = state.copyWith(items: [record, ...state.items]);
      return true;
    } on Object catch (error) {
      state = state.copyWith(lastError: error.toString());
      return false;
    }
  }

  Future<TransactionRecord?> fetchById(String transactionId) {
    return ref.read(transactionRepositoryProvider).fetchById(transactionId);
  }

  Future<bool> transition({
    required String transactionId,
    required String actorUserId,
    required TransactionState nextState,
  }) async {
    try {
      final updated = await ref
          .read(transactionRepositoryProvider)
          .transition(
            transactionId: transactionId,
            actorUserId: actorUserId,
            nextState: nextState,
          );
      final next = state.items
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      state = state.copyWith(items: next);
      return true;
    } on Object catch (error) {
      state = state.copyWith(lastError: error.toString());
      return false;
    }
  }
}

final transactionProvider =
    NotifierProvider<TransactionNotifier, TransactionStateView>(
      TransactionNotifier.new,
    );

// ignore: specify_nonobvious_property_types, Riverpod family typedefs vary in this repo setup.
final transactionDetailProvider =
    FutureProvider.family<TransactionRecord?, String>((
      ref,
      transactionId,
    ) {
      return ref.read(transactionRepositoryProvider).fetchById(transactionId);
    });
