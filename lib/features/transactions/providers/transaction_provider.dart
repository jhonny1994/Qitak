import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';

class TransactionStateView {
  const TransactionStateView({
    this.items = const <TransactionRecord>[],
    this.lastError,
    this.lastErrorCode,
  });

  final List<TransactionRecord> items;
  final String? lastError;
  final AppErrorCode? lastErrorCode;

  TransactionStateView copyWith({
    List<TransactionRecord>? items,
    String? lastError,
    AppErrorCode? lastErrorCode,
    bool clearLastError = false,
  }) {
    return TransactionStateView(
      items: items ?? this.items,
      lastError: clearLastError ? null : lastError ?? this.lastError,
      lastErrorCode: clearLastError
          ? null
          : lastErrorCode ?? this.lastErrorCode,
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
    state = state.copyWith(items: items, clearLastError: true);
  }

  Future<bool> createRequest({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
    String dealType = 'buy',
    String? exchangeOffer,
  }) async {
    try {
      final record = await ref
          .read(transactionRepositoryProvider)
          .createRequest(
            listingId: listingId,
            buyerUserId: buyerUserId,
            sellerUserId: sellerUserId,
            dealType: dealType,
            exchangeOffer: exchangeOffer,
          );
      state = state.copyWith(
        items: [record, ...state.items],
        clearLastError: true,
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        lastError: error.toString(),
        lastErrorCode: _errorCode(error),
      );
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
      state = state.copyWith(items: next, clearLastError: true);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        lastError: error.toString(),
        lastErrorCode: _errorCode(error),
      );
      return false;
    }
  }

  Future<bool> selectPaymentMethod({
    required String transactionId,
    required String actorUserId,
    required TransactionPaymentMethod paymentMethod,
  }) async {
    try {
      final updated = await ref
          .read(transactionRepositoryProvider)
          .selectPaymentMethod(
            transactionId: transactionId,
            actorUserId: actorUserId,
            paymentMethod: paymentMethod,
          );
      final next = state.items
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      state = state.copyWith(items: next, clearLastError: true);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        lastError: error.toString(),
        lastErrorCode: _errorCode(error),
      );
      return false;
    }
  }

  Future<bool> submitPaymentProof({
    required String transactionId,
    required String actorUserId,
    required ListingMediaSelection proof,
  }) async {
    try {
      final updated = await ref
          .read(transactionRepositoryProvider)
          .submitPaymentProof(
            transactionId: transactionId,
            actorUserId: actorUserId,
            proof: proof,
          );
      final next = state.items
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      state = state.copyWith(items: next, clearLastError: true);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        lastError: error.toString(),
        lastErrorCode: _errorCode(error),
      );
      return false;
    }
  }

  Future<bool> rejectPaymentProof({
    required String transactionId,
    required String actorUserId,
  }) async {
    try {
      final updated = await ref
          .read(transactionRepositoryProvider)
          .rejectPaymentProof(
            transactionId: transactionId,
            actorUserId: actorUserId,
          );
      final next = state.items
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      state = state.copyWith(items: next, clearLastError: true);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        lastError: error.toString(),
        lastErrorCode: _errorCode(error),
      );
      return false;
    }
  }

  AppErrorCode? _errorCode(Object error) {
    if (error is AppException) {
      return error.code ?? appErrorCodeFromToken(error.message);
    }
    return appErrorCodeFromToken(error.toString());
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
