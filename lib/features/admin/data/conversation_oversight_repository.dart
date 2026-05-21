import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/admin/domain/conversation_oversight_case.dart';
import 'package:qitak_app/features/messaging/domain/conversation_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConversationOversightRepository {
  const ConversationOversightRepository();

  Future<ConversationOversightCase> loadCase({
    required String threadId,
    required String purpose,
    String? note,
  }) {
    throw UnimplementedError();
  }

  Future<void> attachNote({
    required String threadId,
    required String purpose,
    required String note,
  }) {
    throw UnimplementedError();
  }
}

final conversationOversightRepositoryProvider =
    Provider<ConversationOversightRepository>((ref) {
      final client = ref.watch(supabaseClientProvider);
      if (client == null) {
        throw StateError(
          'Supabase client is required for conversation oversight.',
        );
      }
      return SupabaseConversationOversightRepository(client);
    });

class SupabaseConversationOversightRepository
    implements ConversationOversightRepository {
  const SupabaseConversationOversightRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<ConversationOversightCase> loadCase({
    required String threadId,
    required String purpose,
    String? note,
  }) async {
    await attachNote(
      threadId: threadId,
      purpose: purpose,
      note: note ?? '',
    );

    final thread = await _client
        .from('conversations')
        .select('id, listing_id, buyer_id, seller_id')
        .eq('id', threadId)
        .maybeSingle();
    if (thread == null) {
      throw const AppException('Conversation thread not found.');
    }

    final listingId = thread['listing_id'] as String? ?? '';
    final buyerUserId = thread['buyer_id'] as String? ?? '';
    final sellerUserId = thread['seller_id'] as String? ?? '';

    final listingFuture = _client
        .from('listings')
        .select('id, title')
        .eq('id', listingId)
        .maybeSingle();
    final profilesFuture = _client
        .from('profiles')
        .select('id, full_name')
        .inFilter('id', [buyerUserId, sellerUserId]);
    final messagesFuture = _client
        .from('messages')
        .select('id, conversation_id, sender_id, content, created_at')
        .eq('conversation_id', threadId)
        .order('created_at');
    final transactionFuture = _client
        .from('deals')
        .select('id')
        .eq('listing_id', listingId)
        .eq('buyer_id', buyerUserId)
        .eq('seller_id', sellerUserId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    final reportsFuture = _client
        .from('reports')
        .select('id, reported_entity_type, reported_entity_id, status')
        .inFilter('status', ['open', 'under_review'])
        .or('reported_entity_id.eq.$listingId,reported_entity_id.eq.$threadId')
        .order('created_at', ascending: false)
        .limit(1);

    final listing = await listingFuture;
    final profiles = await profilesFuture;
    final messages = await messagesFuture;
    final transaction = await transactionFuture;
    final reports = await reportsFuture;

    String? disputeId;
    final transactionId = transaction?['id'] as String?;
    if (transactionId != null && transactionId.isNotEmpty) {
      final dispute = await _client
          .from('disputes')
          .select('id')
          .eq('deal_id', transactionId)
          .inFilter('status', ['open', 'under_review'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      disputeId = dispute?['id'] as String?;
    }

    final namesById = <String, String>{
      for (final row in profiles.whereType<Map<String, dynamic>>())
        row['id'] as String: row['full_name'] as String? ?? '',
    };

    return ConversationOversightCase(
      threadId: threadId,
      listingId: listingId,
      listingTitle: listing?['title'] as String? ?? '',
      buyerUserId: buyerUserId,
      sellerUserId: sellerUserId,
      buyerName: namesById[buyerUserId] ?? '',
      sellerName: namesById[sellerUserId] ?? '',
      messages: messages
          .whereType<Map<String, dynamic>>()
          .map(
            (row) => ConversationMessage(
              id: row['id'] as String,
              threadId: row['conversation_id'] as String? ?? threadId,
              body: row['content'] as String? ?? '',
              senderId: row['sender_id'] as String? ?? '',
              createdAt:
                  DateTime.tryParse(
                    row['created_at'] as String? ?? '',
                  )?.toLocal() ??
                  DateTime.now(),
            ),
          )
          .toList(growable: false),
      transactionId: transactionId,
      reportId: reports.isEmpty ? null : reports.first['id'] as String?,
      disputeId: disputeId,
    );
  }

  @override
  Future<void> attachNote({
    required String threadId,
    required String purpose,
    required String note,
  }) async {
    try {
      await _client.rpc<dynamic>(
        'admin_log_conversation_access',
        params: <String, dynamic>{
          'p_thread_id': threadId,
          'p_purpose': purpose,
          'p_note': note.trim().isEmpty ? null : note.trim(),
        },
      );
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
  }
}
