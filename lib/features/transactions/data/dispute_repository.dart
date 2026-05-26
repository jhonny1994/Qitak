import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:qitak_app/core/network/domain_key.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/core/network/supabase_error_classifier.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';
import 'package:qitak_app/features/transactions/domain/transaction_dispute.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DisputeRepository {
  const DisputeRepository();

  Future<TransactionDispute> submit({
    required String transactionId,
    required String createdByUserId,
    required String reason,
    required String description,
    List<ListingMediaSelection> evidence = const <ListingMediaSelection>[],
  });

  Future<List<TransactionDispute>> listOpenDisputes();

  Future<TransactionDispute?> fetchById(String disputeId);

  Future<void> resolve({
    required String disputeId,
    required String decision,
    required String reasonCode,
    required String outcomeAction,
    String? note,
  });
}

final disputeRepositoryProvider = Provider<DisputeRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is required for disputes.');
  }
  final contracts = ref.watch(appContractRepositoryProvider);
  return SupabaseDisputeRepository(client, contracts);
});

class SupabaseDisputeRepository implements DisputeRepository {
  const SupabaseDisputeRepository(this._client, this._contracts);

  final SupabaseClient _client;
  final AppContractRepository _contracts;

  static const _bucket = 'dispute-evidence';

  @override
  Future<TransactionDispute?> fetchById(String disputeId) async {
    final row = await _client
        .from('disputes')
        .select()
        .eq('id', disputeId)
        .maybeSingle();
    if (row == null) {
      return null;
    }

    final dealId = row['deal_id'] as String? ?? '';
    final deal = dealId.isEmpty
        ? null
        : await _client
              .from('deals')
              .select('listing_id, buyer_id, seller_id')
              .eq('id', dealId)
              .maybeSingle();
    final buyerId = deal?['buyer_id'] as String? ?? '';
    final sellerId = deal?['seller_id'] as String? ?? '';
    final listingId = deal?['listing_id'] as String? ?? '';

    final participantIds = [
      buyerId,
      sellerId,
    ].where((id) => id.isNotEmpty).toList();
    final profiles = participantIds.isEmpty
        ? const <dynamic>[]
        : await _client
              .from('profiles')
              .select('id, full_name')
              .inFilter('id', participantIds);
    final namesById = <String, String>{
      for (final profile in profiles.whereType<Map<String, dynamic>>())
        profile['id'] as String: profile['full_name'] as String? ?? '',
    };

    final listing = listingId.isEmpty
        ? null
        : await _client
              .from('listings')
              .select('title')
              .eq('id', listingId)
              .maybeSingle();

    final conversation =
        (listingId.isEmpty || buyerId.isEmpty || sellerId.isEmpty)
        ? null
        : await _client
              .from('conversations')
              .select('id')
              .eq('listing_id', listingId)
              .eq('buyer_id', buyerId)
              .eq('seller_id', sellerId)
              .maybeSingle();

    final evidenceRows = await _client
        .from('dispute_evidence')
        .select('id, storage_path')
        .eq('dispute_id', disputeId)
        .order('created_at');
    final evidence = <DisputeEvidenceItem>[];
    for (final item in evidenceRows.whereType<Map<String, dynamic>>()) {
      final storagePath = item['storage_path'] as String? ?? '';
      final previewUrl = storagePath.isEmpty
          ? ''
          : await _client.storage
                .from(_bucket)
                .createSignedUrl(storagePath, 600);
      evidence.add(
        DisputeEvidenceItem(
          id: item['id'] as String,
          storagePath: storagePath,
          previewUrl: previewUrl,
        ),
      );
    }

    return _mapRow(
      row,
      buyerName: namesById[buyerId] ?? buyerId,
      sellerName: namesById[sellerId] ?? sellerId,
      listingTitle: listing?['title'] as String? ?? '',
      conversationId: conversation?['id'] as String?,
      evidence: evidence,
    );
  }

  @override
  Future<List<TransactionDispute>> listOpenDisputes() async {
    final queueStatuses = await _queueStatuses();
    final rows = await _client
        .from('disputes')
        .select()
        .inFilter('status', queueStatuses)
        .order('created_at', ascending: false);
    final disputes = <TransactionDispute>[];
    for (final row in rows.whereType<Map<String, dynamic>>()) {
      disputes.add(await fetchById(row['id'] as String) ?? _mapRow(row));
    }
    return disputes;
  }

  @override
  Future<TransactionDispute> submit({
    required String transactionId,
    required String createdByUserId,
    required String reason,
    required String description,
    List<ListingMediaSelection> evidence = const <ListingMediaSelection>[],
  }) async {
    late final Map<String, dynamic> row;
    try {
      row = await _client
          .from('disputes')
          .insert(<String, dynamic>{
            'deal_id': transactionId,
            'filed_by': createdByUserId,
            'dispute_type': reason,
            'description': description,
            'status': 'open',
          })
          .select()
          .single();
    } on PostgrestException catch (error) {
      throw AppException.fromCode(classifyPostgrestException(error));
    }

    final disputeId = row['id'] as String;
    for (var index = 0; index < evidence.length; index++) {
      final item = evidence[index];
      final storagePath =
          '$createdByUserId/$disputeId/${index}_${_sanitizeFileName(item.fileName)}';
      await _client.storage
          .from(_bucket)
          .uploadBinary(
            storagePath,
            item.bytes,
            fileOptions: FileOptions(contentType: item.mimeType),
          );
      await _client.from('dispute_evidence').insert(<String, dynamic>{
        'dispute_id': disputeId,
        'uploaded_by': createdByUserId,
        'storage_path': storagePath,
      });
    }
    return await fetchById(disputeId) ?? _mapRow(row);
  }

  @override
  Future<void> resolve({
    required String disputeId,
    required String decision,
    required String reasonCode,
    required String outcomeAction,
    String? note,
  }) async {
    try {
      await _client.rpc<dynamic>(
        'admin_resolve_dispute',
        params: <String, dynamic>{
          'p_dispute_id': disputeId,
          'p_decision': decision,
          'p_reason_code': reasonCode,
          'p_outcome_action': outcomeAction,
          'p_note': note,
        },
      );
    } on PostgrestException catch (error) {
      throw AppException.fromCode(classifyPostgrestException(error));
    }
  }

  TransactionDispute _mapRow(
    Map<String, dynamic> row, {
    String buyerName = '',
    String sellerName = '',
    String listingTitle = '',
    String? conversationId,
    List<DisputeEvidenceItem> evidence = const <DisputeEvidenceItem>[],
  }) {
    return TransactionDispute(
      id: row['id'] as String,
      transactionId: row['deal_id'] as String? ?? '',
      createdByUserId: row['filed_by'] as String? ?? '',
      reason: row['dispute_type'] as String? ?? '',
      description: row['description'] as String? ?? '',
      status: row['status'] as String? ?? 'open',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      buyerName: buyerName,
      sellerName: sellerName,
      listingTitle: listingTitle,
      conversationId: conversationId,
      evidence: evidence,
    );
  }

  String _sanitizeFileName(String raw) {
    final cleaned = raw.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
    return cleaned.isEmpty ? 'dispute_evidence.jpg' : cleaned;
  }

  Future<List<String>> _queueStatuses() async {
    final statusSet = await _contracts.fetchDomainCodes(
      DomainKey.disputeStatus,
    );
    final queue = statusSet
        .where((code) => code == 'open' || code == 'under_review')
        .toList(growable: false);
    if (queue.isEmpty) {
      throw AppException.fromCode(AppErrorCode.contractUnavailable);
    }
    return queue;
  }
}

class LocalDisputeRepository implements DisputeRepository {
  const LocalDisputeRepository();

  @override
  Future<TransactionDispute?> fetchById(String disputeId) async {
    for (final item in await listOpenDisputes()) {
      if (item.id == disputeId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<TransactionDispute>> listOpenDisputes() async {
    return const <TransactionDispute>[];
  }

  @override
  Future<TransactionDispute> submit({
    required String transactionId,
    required String createdByUserId,
    required String reason,
    required String description,
    List<ListingMediaSelection> evidence = const <ListingMediaSelection>[],
  }) async {
    return TransactionDispute(
      id: 'dispute-$transactionId',
      transactionId: transactionId,
      createdByUserId: createdByUserId,
      reason: reason,
      description: description,
      status: 'open',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> resolve({
    required String disputeId,
    required String decision,
    required String reasonCode,
    required String outcomeAction,
    String? note,
  }) async {}
}

final FutureProvider<List<TransactionDispute>> adminDisputesProvider =
    FutureProvider<List<TransactionDispute>>((ref) {
      return ref.read(disputeRepositoryProvider).listOpenDisputes();
    });

// ignore: specify_nonobvious_property_types, reason: Riverpod family aliases are version-specific in this repo.
final adminDisputeProvider = FutureProvider.family<TransactionDispute?, String>(
  (
    ref,
    disputeId,
  ) {
    return ref.read(disputeRepositoryProvider).fetchById(disputeId);
  },
);
