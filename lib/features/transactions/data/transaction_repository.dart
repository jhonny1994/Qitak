import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:qitak_app/core/network/domain_key.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/core/network/supabase_error_classifier.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TransactionRepository {
  const TransactionRepository();

  Future<TransactionRecord> createRequest({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
    String dealType = 'buy',
    String? exchangeOffer,
  });

  Future<List<TransactionRecord>> listForUser(String userId);

  Future<TransactionRecord?> fetchById(String transactionId);

  Future<TransactionRecord> transition({
    required String transactionId,
    required String actorUserId,
    required TransactionState nextState,
  });

  Future<TransactionRecord> selectPaymentMethod({
    required String transactionId,
    required String actorUserId,
    required TransactionPaymentMethod paymentMethod,
  });

  Future<TransactionRecord> submitPaymentProof({
    required String transactionId,
    required String actorUserId,
    required ListingMediaSelection proof,
  });

  Future<TransactionRecord> rejectPaymentProof({
    required String transactionId,
    required String actorUserId,
  });

  Future<bool> canSubmitRating({
    required String transactionId,
    required String fromUserId,
    required String toUserId,
  });
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  if (client == null) {
    throw StateError('Supabase client is required for transactions.');
  }
  return SupabaseTransactionRepository(
    client,
    AppContractRepository(client, prefs),
  );
});

class PaymentProofWriteCoordinator {
  const PaymentProofWriteCoordinator();

  Future<T> execute<T>({
    required Future<void> Function() uploadProof,
    required Future<T> Function() persistProof,
    required Future<void> Function() rollbackUpload,
  }) async {
    await uploadProof();
    try {
      return await persistProof();
    } on Object {
      try {
        await rollbackUpload();
      } on Object catch (_) {
        // Preserve the original persistence failure; rollback is best effort.
      }
      rethrow;
    }
  }
}

class LocalTransactionRepository implements TransactionRepository {
  static final Map<String, TransactionRecord> _records =
      <String, TransactionRecord>{};
  static int _id = 1;
  static const _proofBucket = 'deal-payment-proofs';

  static void resetForTest() {
    _records.clear();
    _id = 1;
  }

  @override
  Future<TransactionRecord> createRequest({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
    String dealType = 'buy',
    String? exchangeOffer,
  }) async {
    final hasActive = _records.values.any(
      (item) =>
          item.listingId == listingId &&
          !item.state.isClosed &&
          item.state != TransactionState.disputeResolved,
    );
    if (hasActive) {
      throw AppException.fromCode(AppErrorCode.conflict);
    }
    final id = 'tx-${_id++}';
    final now = DateTime.now();
    final record = TransactionRecord(
      id: id,
      listingId: listingId,
      buyerUserId: buyerUserId,
      sellerUserId: sellerUserId,
      state: TransactionState.pendingSellerResponse,
      dealType: dealType,
      exchangeOffer: exchangeOffer,
      createdAt: now,
      updatedAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );
    _records[id] = record;
    return record;
  }

  @override
  Future<List<TransactionRecord>> listForUser(String userId) async {
    return _records.values
        .where(
          (item) => item.buyerUserId == userId || item.sellerUserId == userId,
        )
        .toList()
      ..sort((a, b) => b.id.compareTo(a.id));
  }

  @override
  Future<TransactionRecord?> fetchById(String transactionId) async {
    return _records[transactionId];
  }

  @override
  Future<TransactionRecord> transition({
    required String transactionId,
    required String actorUserId,
    required TransactionState nextState,
  }) async {
    final current = _records[transactionId];
    if (current == null) {
      throw AppException.fromCode(AppErrorCode.notFound);
    }
    final allowed = _isAllowedTransition(
      current: current,
      actorUserId: actorUserId,
      nextState: nextState,
    );
    if (!allowed) {
      throw AppException.fromCode(AppErrorCode.permissionDenied);
    }
    final now = DateTime.now();
    final updated = current.copyWith(
      state: nextState,
      updatedAt: now,
      confirmedAt: nextState == TransactionState.sellerConfirmed
          ? now
          : current.confirmedAt,
      paymentConfirmedAt: nextState == TransactionState.paymentConfirmed
          ? now
          : current.paymentConfirmedAt,
      completedAt: nextState == TransactionState.completed
          ? now
          : current.completedAt,
      cancelledAt: nextState == TransactionState.cancelled
          ? now
          : current.cancelledAt,
    );
    _records[transactionId] = updated;
    return updated;
  }

  @override
  Future<TransactionRecord> selectPaymentMethod({
    required String transactionId,
    required String actorUserId,
    required TransactionPaymentMethod paymentMethod,
  }) async {
    final current = _records[transactionId];
    if (current == null) {
      throw AppException.fromCode(AppErrorCode.notFound);
    }
    if (current.buyerUserId != actorUserId ||
        current.state != TransactionState.sellerConfirmed) {
      throw AppException.fromCode(AppErrorCode.permissionDenied);
    }
    final updated = current.copyWith(
      paymentMethod: paymentMethod,
      updatedAt: DateTime.now(),
      clearPaymentProofPath: true,
      clearPaymentProofSubmittedAt: true,
      clearPaymentConfirmedAt: true,
    );
    _records[transactionId] = updated;
    return updated;
  }

  @override
  Future<TransactionRecord> submitPaymentProof({
    required String transactionId,
    required String actorUserId,
    required ListingMediaSelection proof,
  }) async {
    final current = _records[transactionId];
    if (current == null) {
      throw AppException.fromCode(AppErrorCode.notFound);
    }
    if (current.buyerUserId != actorUserId ||
        current.state != TransactionState.sellerConfirmed ||
        !current.requiresPaymentProof) {
      throw AppException.fromCode(AppErrorCode.permissionDenied);
    }
    final now = DateTime.now();
    final updated = current.copyWith(
      state: TransactionState.paymentProofSubmitted,
      paymentProofPath:
          '$_proofBucket/$actorUserId/$transactionId/${proof.fileName}',
      paymentProofSubmittedAt: now,
      updatedAt: now,
      clearPaymentConfirmedAt: true,
    );
    _records[transactionId] = updated;
    return updated;
  }

  @override
  Future<TransactionRecord> rejectPaymentProof({
    required String transactionId,
    required String actorUserId,
  }) async {
    final current = _records[transactionId];
    if (current == null) {
      throw AppException.fromCode(AppErrorCode.notFound);
    }
    if (current.sellerUserId != actorUserId ||
        current.state != TransactionState.paymentProofSubmitted) {
      throw AppException.fromCode(AppErrorCode.permissionDenied);
    }
    final updated = current.copyWith(
      state: TransactionState.sellerConfirmed,
      updatedAt: DateTime.now(),
      clearPaymentProofPath: true,
      clearPaymentProofSubmittedAt: true,
      clearPaymentConfirmedAt: true,
    );
    _records[transactionId] = updated;
    return updated;
  }

  @override
  Future<bool> canSubmitRating({
    required String transactionId,
    required String fromUserId,
    required String toUserId,
  }) async {
    final tx = _records[transactionId];
    if (tx == null) {
      return false;
    }
    if (tx.state != TransactionState.completed) {
      return false;
    }
    final isParticipant =
        (tx.buyerUserId == fromUserId && tx.sellerUserId == toUserId) ||
        (tx.sellerUserId == fromUserId && tx.buyerUserId == toUserId);
    return isParticipant;
  }

  bool _isAllowedTransition({
    required TransactionRecord current,
    required String actorUserId,
    required TransactionState nextState,
  }) {
    final isBuyer = actorUserId == current.buyerUserId;
    final isSeller = actorUserId == current.sellerUserId;
    if (!isBuyer && !isSeller) {
      return false;
    }
    switch (current.state) {
      case TransactionState.pendingSellerResponse:
        if (nextState == TransactionState.sellerConfirmed) return isSeller;
        if (nextState == TransactionState.cancelled) return isBuyer || isSeller;
        if (nextState == TransactionState.disputeOpened) return false;
        return false;
      case TransactionState.sellerConfirmed:
        if (nextState == TransactionState.completed) {
          return current.isCashPayment && isSeller;
        }
        if (nextState == TransactionState.cancelled) return isBuyer || isSeller;
        if (nextState == TransactionState.disputeOpened) return false;
        return false;
      case TransactionState.paymentProofSubmitted:
        if (nextState == TransactionState.paymentConfirmed) return isSeller;
        if (nextState == TransactionState.cancelled) return isBuyer || isSeller;
        if (nextState == TransactionState.disputeOpened) {
          return isBuyer || isSeller;
        }
        return false;
      case TransactionState.paymentConfirmed:
        if (nextState == TransactionState.completed) return isBuyer;
        if (nextState == TransactionState.disputeOpened) {
          return isBuyer || isSeller;
        }
        return false;
      case TransactionState.disputeOpened:
        if (nextState == TransactionState.disputeResolved) {
          return isSeller || isBuyer;
        }
        return false;
      case TransactionState.expired:
      case TransactionState.completed:
      case TransactionState.cancelled:
      case TransactionState.disputeResolved:
        return false;
    }
  }
}

class SupabaseTransactionRepository implements TransactionRepository {
  SupabaseTransactionRepository(this._client, this._contracts);

  final SupabaseClient _client;
  final AppContractRepository _contracts;
  Set<String>? _cachedDealStates;
  static const _proofBucket = 'deal-payment-proofs';

  @override
  Future<TransactionRecord> createRequest({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
    String dealType = 'buy',
    String? exchangeOffer,
  }) async {
    try {
      final created = await _client.rpc<Map<String, dynamic>>(
        'create_deal_request',
        params: <String, dynamic>{
          'p_listing_id': listingId,
          'p_buyer_id': buyerUserId,
          'p_seller_id': sellerUserId,
          'p_deal_type': dealType,
          'p_exchange_offer': exchangeOffer,
        },
      );
      return _fromMap(created);
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw AppException.fromCode(AppErrorCode.conflict);
      }
      throw AppException.fromCode(classifyPostgrestException(error));
    }
  }

  @override
  Future<List<TransactionRecord>> listForUser(String userId) async {
    final rows = await _client
        .from('deals')
        .select()
        .or('buyer_id.eq.$userId,seller_id.eq.$userId');
    return rows.map<TransactionRecord>(_fromMap).toList();
  }

  @override
  Future<TransactionRecord?> fetchById(String transactionId) async {
    final row = await _client
        .from('deals')
        .select()
        .eq('id', transactionId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return _fromMap(row);
  }

  @override
  Future<TransactionRecord> transition({
    required String transactionId,
    required String actorUserId,
    required TransactionState nextState,
  }) async {
    final _ = actorUserId;
    final knownStates = await _dealStates();
    if (!knownStates.contains(nextState.value)) {
      throw AppException.fromCode(AppErrorCode.validationFailed);
    }
    try {
      final updated = await _client.rpc<Map<String, dynamic>>(
        'transition_deal',
        params: <String, dynamic>{
          'p_deal_id': transactionId,
          'p_next_status': nextState.value,
        },
      );
      return _fromMap(updated);
    } on PostgrestException catch (error) {
      final mapped = classifyPostgrestException(error);
      if (mapped == AppErrorCode.notFound) {
        throw AppException.fromCode(AppErrorCode.notFound);
      }
      if (mapped == AppErrorCode.permissionDenied) {
        throw AppException.fromCode(AppErrorCode.permissionDenied);
      }
      throw AppException.fromCode(mapped);
    }
  }

  @override
  Future<TransactionRecord> selectPaymentMethod({
    required String transactionId,
    required String actorUserId,
    required TransactionPaymentMethod paymentMethod,
  }) async {
    final _ = actorUserId;
    try {
      final updated = await _client.rpc<Map<String, dynamic>>(
        'select_deal_payment_method',
        params: <String, dynamic>{
          'p_deal_id': transactionId,
          'p_payment_method': paymentMethod.value,
        },
      );
      return _fromMap(updated);
    } on PostgrestException catch (error) {
      throw AppException.fromCode(classifyPostgrestException(error));
    }
  }

  @override
  Future<TransactionRecord> submitPaymentProof({
    required String transactionId,
    required String actorUserId,
    required ListingMediaSelection proof,
  }) async {
    final storagePath =
        '$actorUserId/$transactionId/${_sanitizeFileName(proof.fileName)}';
    try {
      return await const PaymentProofWriteCoordinator().execute(
        uploadProof: () {
          return _client.storage
              .from(_proofBucket)
              .uploadBinary(
                storagePath,
                proof.bytes,
                fileOptions: FileOptions(contentType: proof.mimeType),
              );
        },
        persistProof: () async {
          final updated = await _client.rpc<Map<String, dynamic>>(
            'submit_deal_payment_proof',
            params: <String, dynamic>{
              'p_deal_id': transactionId,
              'p_storage_path': storagePath,
            },
          );
          return _fromMap(updated);
        },
        rollbackUpload: () async {
          await _client.storage.from(_proofBucket).remove(<String>[storagePath]);
        },
      );
    } on StorageException catch (_) {
      throw AppException.fromCode(AppErrorCode.networkUnavailable);
    } on PostgrestException catch (error) {
      throw AppException.fromCode(classifyPostgrestException(error));
    }
  }

  @override
  Future<TransactionRecord> rejectPaymentProof({
    required String transactionId,
    required String actorUserId,
  }) async {
    final _ = actorUserId;
    try {
      final updated = await _client.rpc<Map<String, dynamic>>(
        'reject_deal_payment_proof',
        params: <String, dynamic>{
          'p_deal_id': transactionId,
        },
      );
      return _fromMap(updated);
    } on PostgrestException catch (error) {
      throw AppException.fromCode(classifyPostgrestException(error));
    }
  }

  @override
  Future<bool> canSubmitRating({
    required String transactionId,
    required String fromUserId,
    required String toUserId,
  }) async {
    final row = await _client
        .from('deals')
        .select('status,buyer_id,seller_id')
        .eq('id', transactionId)
        .maybeSingle();
    if (row == null) {
      return false;
    }
    final state = TransactionStateX.fromValue(row['status'] as String);
    if (state != TransactionState.completed) {
      return false;
    }
    final buyer = row['buyer_id'] as String;
    final seller = row['seller_id'] as String;
    return (buyer == fromUserId && seller == toUserId) ||
        (seller == fromUserId && buyer == toUserId);
  }

  TransactionRecord _fromMap(Map<String, dynamic> row) {
    final rawState =
        row['status'] as String? ??
        TransactionStateCatalog.pendingSellerResponse;
    return TransactionRecord(
      id: row['id'] as String,
      listingId: row['listing_id'] as String,
      buyerUserId: row['buyer_id'] as String,
      sellerUserId: row['seller_id'] as String,
      state: TransactionStateX.fromValue(rawState),
      dealType: row['deal_type'] as String? ?? 'buy',
      exchangeOffer: row['exchange_offer'] as String?,
      paymentMethod: TransactionPaymentMethodX.fromValue(
        row['payment_method'] as String?,
      ),
      paymentProofPath: row['payment_proof_path'] as String?,
      expiresAt: DateTime.tryParse(
        row['expires_at'] as String? ?? '',
      )?.toLocal(),
      confirmedAt: DateTime.tryParse(
        row['confirmed_at'] as String? ?? '',
      )?.toLocal(),
      paymentProofSubmittedAt: DateTime.tryParse(
        row['payment_proof_submitted_at'] as String? ?? '',
      )?.toLocal(),
      paymentConfirmedAt: DateTime.tryParse(
        row['payment_confirmed_at'] as String? ?? '',
      )?.toLocal(),
      completedAt: DateTime.tryParse(
        row['completed_at'] as String? ?? '',
      )?.toLocal(),
      cancelledAt: DateTime.tryParse(
        row['cancelled_at'] as String? ?? '',
      )?.toLocal(),
      createdAt: DateTime.tryParse(
        row['created_at'] as String? ?? '',
      )?.toLocal(),
      updatedAt: DateTime.tryParse(
        row['updated_at'] as String? ?? '',
      )?.toLocal(),
    );
  }

  Future<Set<String>> _dealStates() async {
    final cached = _cachedDealStates;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final states = await _contracts.fetchDomainCodes(DomainKey.dealStatus);
    final set = states.toSet();
    if (set.isEmpty) {
      throw AppException.fromCode(AppErrorCode.contractUnavailable);
    }
    _cachedDealStates = set;
    return set;
  }

  String _sanitizeFileName(String raw) {
    final cleaned = raw.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
    return cleaned.isEmpty ? 'payment_proof.jpg' : cleaned;
  }
}
