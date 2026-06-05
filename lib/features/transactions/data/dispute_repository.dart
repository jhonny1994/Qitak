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

class DisputeSubmissionCoordinator {
  const DisputeSubmissionCoordinator();

  Future<T> execute<T>({
    required List<ListingMediaSelection> evidence,
    required Future<String> Function() createDraft,
    required Future<String> Function(
      String disputeId,
      int index,
      ListingMediaSelection item,
    )
    uploadEvidence,
    required Future<void> Function(String disputeId, String storagePath)
    persistEvidence,
    required Future<T> Function(String disputeId) finish,
    required Future<void> Function(String disputeId, List<String> uploadedPaths)
    rollback,
  }) async {
    final disputeId = await createDraft();
    final uploadedPaths = <String>[];
    try {
      for (var index = 0; index < evidence.length; index++) {
        final item = evidence[index];
        final storagePath = await uploadEvidence(disputeId, index, item);
        uploadedPaths.add(storagePath);
        await persistEvidence(disputeId, storagePath);
      }
      return await finish(disputeId);
    } on Object {
      try {
        await rollback(disputeId, uploadedPaths);
      } on Object {
        // Preserve the original submission failure; rollback is best effort.
      }
      rethrow;
    }
  }
}

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
    late Map<String, dynamic> row;
    try {
      return await const DisputeSubmissionCoordinator().execute<TransactionDispute>(
        evidence: evidence,
        createDraft: () async {
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
          return row['id'] as String;
        },
        uploadEvidence: (disputeId, index, item) async {
          final storagePath =
              '$createdByUserId/$disputeId/${index}_${_sanitizeFileName(item.fileName)}';
          await _client.storage
              .from(_bucket)
              .uploadBinary(
                storagePath,
                item.bytes,
                fileOptions: FileOptions(contentType: item.mimeType),
              );
          return storagePath;
        },
        persistEvidence: (disputeId, storagePath) {
          return _client.from('dispute_evidence').insert(<String, dynamic>{
            'dispute_id': disputeId,
            'uploaded_by': createdByUserId,
            'storage_path': storagePath,
          });
        },
        finish: (disputeId) async => await fetchById(disputeId) ?? _mapRow(row),
        rollback: (disputeId, uploadedPaths) async {
          if (uploadedPaths.isNotEmpty) {
            await _client
                .from('dispute_evidence')
                .delete()
                .eq('dispute_id', disputeId);
            await _client.storage.from(_bucket).remove(uploadedPaths);
          }
          await _client.from('disputes').delete().eq('id', disputeId);
        },
      );
    } on PostgrestException catch (error) {
      throw AppException.fromCode(classifyPostgrestException(error));
    } on StorageException catch (_) {
      throw AppException.fromCode(AppErrorCode.networkUnavailable);
    }
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

  static final List<TransactionDispute> _disputes = <TransactionDispute>[];

  static void resetForTest() {
    _disputes.clear();
  }

  @override
  Future<TransactionDispute?> fetchById(String disputeId) async {
    for (final item in _disputes) {
      if (item.id == disputeId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<TransactionDispute>> listOpenDisputes() async {
    return _disputes
        .where((item) => item.status == 'open' || item.status == 'under_review')
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<TransactionDispute> submit({
    required String transactionId,
    required String createdByUserId,
    required String reason,
    required String description,
    List<ListingMediaSelection> evidence = const <ListingMediaSelection>[],
  }) async {
    final dispute = TransactionDispute(
      id: 'dispute-${_disputes.length + 1}',
      transactionId: transactionId,
      createdByUserId: createdByUserId,
      reason: reason,
      description: description,
      status: 'open',
      createdAt: DateTime.now(),
      evidence: [
        for (var index = 0; index < evidence.length; index++)
          DisputeEvidenceItem(
            id: 'evidence-${_disputes.length + 1}-$index',
            storagePath:
                '$createdByUserId/dispute-${_disputes.length + 1}/${evidence[index].fileName}',
            previewUrl: evidence[index].toDataUri(),
          ),
      ],
    );
    _disputes
      ..removeWhere((item) => item.id == dispute.id)
      ..insert(0, dispute);
    return dispute;
  }

  @override
  Future<void> resolve({
    required String disputeId,
    required String decision,
    required String reasonCode,
    required String outcomeAction,
    String? note,
  }) async {
    final index = _disputes.indexWhere((item) => item.id == disputeId);
    if (index == -1) {
      return;
    }
    final current = _disputes[index];
    final nextStatus = switch (decision) {
      'buyer' => 'resolved_buyer',
      'seller' => 'resolved_seller',
      'dismiss' => 'dismissed',
      _ => current.status,
    };
    _disputes[index] = TransactionDispute(
      id: current.id,
      transactionId: current.transactionId,
      createdByUserId: current.createdByUserId,
      reason: current.reason,
      description: current.description,
      status: nextStatus,
      createdAt: current.createdAt,
      buyerName: current.buyerName,
      sellerName: current.sellerName,
      listingTitle: current.listingTitle,
      conversationId: current.conversationId,
      evidence: current.evidence,
    );
  }
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
