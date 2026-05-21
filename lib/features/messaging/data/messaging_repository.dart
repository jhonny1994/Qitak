import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/constants/app_constants.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/messaging/domain/conversation_message.dart';
import 'package:qitak_app/features/messaging/domain/conversation_thread_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class MessagingRepository {
  const MessagingRepository();

  bool get isLocal;

  Future<String> ensureThread({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
  });

  Future<List<ConversationThreadSummary>> listThreadsForUser(String userId);

  Future<List<ConversationMessage>> listMessages({
    required String threadId,
    required String userId,
  });

  Future<List<ConversationMessage>> listMessagesAfter({
    required String threadId,
    required String userId,
    required DateTime after,
  }) async {
    final _ = (threadId, userId, after);
    return const <ConversationMessage>[];
  }

  Future<int> countUnreadMessages(String userId) async {
    final _ = userId;
    return 0;
  }

  Future<void> markThreadMessagesRead({
    required String threadId,
    required String userId,
  }) async {
    final _ = (threadId, userId);
  }

  Future<void> markAllMessagesRead(String userId) async {
    final _ = userId;
  }

  List<RealtimeChannel> subscribeToConversationListChanges({
    required String userId,
    required void Function() onChange,
    required void Function(Object error) onError,
  }) {
    final _ = (userId, onChange, onError);
    return const <RealtimeChannel>[];
  }

  RealtimeChannel subscribeToThreadMessages({
    required String threadId,
    required void Function(ConversationMessage message) onMessage,
    required void Function() onSubscribed,
    required void Function(Object error) onError,
  }) {
    final _ = (threadId, onMessage, onSubscribed, onError);
    throw UnsupportedError('Realtime messaging is unavailable.');
  }

  Future<void> removeChannel(RealtimeChannel channel) async {
    final _ = channel;
  }

  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String body,
  });
}

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is required for messaging.');
  }
  return SupabaseMessagingRepository(client);
});

class LocalMessagingRepository implements MessagingRepository {
  static final List<Map<String, String>> _messages = <Map<String, String>>[];

  static void resetForTest() {
    _messages.clear();
  }

  @override
  bool get isLocal => true;

  @override
  Future<String> ensureThread({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
  }) async {
    return 'thread-$listingId-$buyerUserId-$sellerUserId';
  }

  @override
  Future<List<ConversationMessage>> listMessages({
    required String threadId,
    required String userId,
  }) async {
    return _messages
        .where((row) => row['threadId'] == threadId)
        .map(
          (row) => ConversationMessage(
            id: row['id'] ?? '',
            threadId: row['threadId'] ?? '',
            body: row['body'] ?? '',
            senderId: row['senderId'] ?? '',
            createdAt:
                DateTime.tryParse(row['createdAt'] ?? '') ?? DateTime.now(),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<ConversationMessage>> listMessagesAfter({
    required String threadId,
    required String userId,
    required DateTime after,
  }) async {
    final _ = userId;
    return _messages
        .where(
          (row) =>
              row['threadId'] == threadId &&
              (DateTime.tryParse(row['createdAt'] ?? '') ?? DateTime.now())
                  .isAfter(after),
        )
        .map(
          (row) => ConversationMessage(
            id: row['id'] ?? '',
            threadId: row['threadId'] ?? '',
            body: row['body'] ?? '',
            senderId: row['senderId'] ?? '',
            createdAt:
                DateTime.tryParse(row['createdAt'] ?? '') ?? DateTime.now(),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<ConversationThreadSummary>> listThreadsForUser(
    String userId,
  ) async {
    final latestByThread = <String, Map<String, String>>{};
    for (final row in _messages) {
      latestByThread[row['threadId'] ?? ''] = row;
    }
    return latestByThread.values
        .where((row) => (row['threadId'] ?? '').isNotEmpty)
        .map(
          (row) => ConversationThreadSummary(
            id: row['threadId'] ?? '',
            listingId: row['listingId'] ?? '',
            listingTitle: kLocalConversationFallbackTitle,
            lastMessageBody: row['body'] ?? '',
            lastMessageAt:
                DateTime.tryParse(row['createdAt'] ?? '') ?? DateTime.now(),
            lastSenderId: row['senderId'] ?? '',
            otherPartyLabel: kLocalConversationFallbackOtherParty,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<int> countUnreadMessages(String userId) async {
    return _messages.where((row) => row['senderId'] != userId).length;
  }

  @override
  Future<void> markThreadMessagesRead({
    required String threadId,
    required String userId,
  }) async {}

  @override
  Future<void> markAllMessagesRead(String userId) async {}

  @override
  List<RealtimeChannel> subscribeToConversationListChanges({
    required String userId,
    required void Function() onChange,
    required void Function(Object error) onError,
  }) {
    final _ = (userId, onChange, onError);
    return const <RealtimeChannel>[];
  }

  @override
  RealtimeChannel subscribeToThreadMessages({
    required String threadId,
    required void Function(ConversationMessage message) onMessage,
    required void Function() onSubscribed,
    required void Function(Object error) onError,
  }) {
    final _ = (threadId, onMessage, onSubscribed, onError);
    throw UnsupportedError('Realtime messaging is unavailable for local mode.');
  }

  @override
  Future<void> removeChannel(RealtimeChannel channel) async {
    final _ = channel;
  }

  @override
  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String body,
  }) async {
    final normalized = body.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(body, 'body', 'Message body cannot be empty.');
    }
    _messages.add(<String, String>{
      'id': '$threadId-${_messages.length + 1}',
      'threadId': threadId,
      'senderId': senderId,
      'body': normalized,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}

class SupabaseMessagingRepository implements MessagingRepository {
  SupabaseMessagingRepository(this._client);

  final SupabaseClient _client;

  @override
  bool get isLocal => false;

  @override
  Future<String> ensureThread({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
  }) async {
    final existing = await _client
        .from('conversations')
        .select('id')
        .eq('listing_id', listingId)
        .eq('buyer_id', buyerUserId)
        .eq('seller_id', sellerUserId)
        .maybeSingle();
    if (existing != null) {
      return existing['id'] as String;
    }
    final created = await _client
        .from('conversations')
        .insert(<String, dynamic>{
          'listing_id': listingId,
          'buyer_id': buyerUserId,
          'seller_id': sellerUserId,
        })
        .select('id')
        .single();
    return created['id'] as String;
  }

  @override
  Future<List<ConversationMessage>> listMessages({
    required String threadId,
    required String userId,
  }) async {
    final rows = await _client
        .from('messages')
        .select('id, conversation_id, sender_id, content, created_at')
        .eq('conversation_id', threadId)
        .order('created_at');
    return rows
        .whereType<Map<String, dynamic>>()
        .map(
          (row) => ConversationMessage(
            id: row['id'] as String,
            threadId: row['conversation_id'] as String,
            body: row['content'] as String? ?? '',
            senderId: row['sender_id'] as String? ?? '',
            createdAt:
                DateTime.tryParse(
                  row['created_at'] as String? ?? '',
                )?.toLocal() ??
                DateTime.now(),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<ConversationMessage>> listMessagesAfter({
    required String threadId,
    required String userId,
    required DateTime after,
  }) async {
    final _ = userId;
    final rows = await _client
        .from('messages')
        .select('id, conversation_id, sender_id, content, created_at')
        .eq('conversation_id', threadId)
        .gt('created_at', after.toUtc().toIso8601String())
        .order('created_at');
    return rows
        .whereType<Map<String, dynamic>>()
        .map(_messageFromRow)
        .toList(growable: false);
  }

  @override
  Future<List<ConversationThreadSummary>> listThreadsForUser(
    String userId,
  ) async {
    final threadRows = await _client
        .from('conversations')
        .select(
          'id, listing_id, buyer_id, seller_id, created_at, last_message_at',
        )
        .or('buyer_id.eq.$userId,seller_id.eq.$userId');
    final threads = threadRows.whereType<Map<String, dynamic>>().toList(
      growable: false,
    );
    if (threads.isEmpty) {
      return const <ConversationThreadSummary>[];
    }

    final threadIds = threads
        .map((row) => row['id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    final listingIds = threads
        .map((row) => row['listing_id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final participantIds = threads
        .expand(
          (row) => [
            row['buyer_id'] as String? ?? '',
            row['seller_id'] as String? ?? '',
          ],
        )
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final listingsFuture = listingIds.isEmpty
        ? Future.value(const <dynamic>[])
        : _client
              .from('listings')
              .select('id, title')
              .inFilter('id', listingIds);
    final profilesFuture = participantIds.isEmpty
        ? Future.value(const <dynamic>[])
        : _client
              .from('profiles')
              .select('id, full_name')
              .inFilter('id', participantIds);
    final messagesFuture = _client
        .from('messages')
        .select('id, conversation_id, sender_id, content, created_at')
        .inFilter('conversation_id', threadIds)
        .order('created_at', ascending: false);

    final results = await Future.wait<List<dynamic>>([
      listingsFuture,
      profilesFuture,
      messagesFuture,
    ]);
    final listingTitleById = <String, String>{
      for (final row in results[0].whereType<Map<String, dynamic>>())
        row['id'] as String: row['title'] as String? ?? '',
    };
    final profileNameById = <String, String>{
      for (final row in results[1].whereType<Map<String, dynamic>>())
        row['id'] as String: row['full_name'] as String? ?? '',
    };
    final latestMessageByThread = <String, Map<String, dynamic>>{};
    for (final row in results[2].whereType<Map<String, dynamic>>()) {
      latestMessageByThread.putIfAbsent(
        row['conversation_id'] as String? ?? '',
        () => row,
      );
    }

    final summaries =
        threads
            .map((row) {
              final threadId = row['id'] as String? ?? '';
              final listingId = row['listing_id'] as String? ?? '';
              final buyerId = row['buyer_id'] as String? ?? '';
              final sellerId = row['seller_id'] as String? ?? '';
              final otherPartyId = buyerId == userId ? sellerId : buyerId;
              final latestMessage = latestMessageByThread[threadId];
              return ConversationThreadSummary(
                id: threadId,
                listingId: listingId,
                listingTitle:
                    listingTitleById[listingId] ??
                    kLocalConversationFallbackTitle,
                lastMessageBody: latestMessage?['content'] as String? ?? '',
                lastMessageAt:
                    DateTime.tryParse(
                      latestMessage?['created_at']?.toString() ?? '',
                    )?.toLocal() ??
                    DateTime.tryParse(
                      row['last_message_at']?.toString() ?? '',
                    )?.toLocal() ??
                    DateTime.tryParse(
                      row['created_at']?.toString() ?? '',
                    )?.toLocal() ??
                    DateTime.now(),
                lastSenderId: latestMessage?['sender_id'] as String? ?? '',
                otherPartyLabel: profileNameById[otherPartyId] ?? '',
              );
            })
            .toList(growable: false)
          ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

    return summaries;
  }

  @override
  Future<int> countUnreadMessages(String userId) async {
    final rows = await _client
        .from('messages')
        .select('sender_id, conversations!inner(buyer_id, seller_id)')
        .eq('is_read', false)
        .neq('sender_id', userId)
        .or(
          'buyer_id.eq.$userId,seller_id.eq.$userId',
          referencedTable: 'conversations',
        );
    return rows.length;
  }

  @override
  Future<void> markThreadMessagesRead({
    required String threadId,
    required String userId,
  }) {
    return _client
        .from('messages')
        .update(<String, dynamic>{'is_read': true})
        .eq('conversation_id', threadId)
        .eq('is_read', false)
        .neq('sender_id', userId);
  }

  @override
  Future<void> markAllMessagesRead(String userId) async {
    final threadRows = await _client
        .from('conversations')
        .select('id')
        .or('buyer_id.eq.$userId,seller_id.eq.$userId');
    final threadIds = threadRows
        .whereType<Map<String, dynamic>>()
        .map((row) => row['id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    if (threadIds.isEmpty) {
      return;
    }
    await _client
        .from('messages')
        .update(<String, dynamic>{'is_read': true})
        .inFilter('conversation_id', threadIds)
        .eq('is_read', false)
        .neq('sender_id', userId);
  }

  @override
  List<RealtimeChannel> subscribeToConversationListChanges({
    required String userId,
    required void Function() onChange,
    required void Function(Object error) onError,
  }) {
    final buyerChannel =
        _client
            .channel('conversations:buyer:$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'conversations',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'buyer_id',
                value: userId,
              ),
              callback: (_) => onChange(),
            )
          ..subscribe((status, error) {
            if (status == RealtimeSubscribeStatus.channelError &&
                error != null) {
              onError(error);
            }
          });

    final sellerChannel =
        _client
            .channel('conversations:seller:$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'conversations',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'seller_id',
                value: userId,
              ),
              callback: (_) => onChange(),
            )
          ..subscribe((status, error) {
            if (status == RealtimeSubscribeStatus.channelError &&
                error != null) {
              onError(error);
            }
          });

    return <RealtimeChannel>[buyerChannel, sellerChannel];
  }

  @override
  RealtimeChannel subscribeToThreadMessages({
    required String threadId,
    required void Function(ConversationMessage message) onMessage,
    required void Function() onSubscribed,
    required void Function(Object error) onError,
  }) {
    final channel =
        _client
            .channel('messages:thread:$threadId')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'messages',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'conversation_id',
                value: threadId,
              ),
              callback: (payload) {
                onMessage(_messageFromRow(payload.newRecord));
              },
            )
          ..subscribe((status, error) {
            switch (status) {
              case RealtimeSubscribeStatus.subscribed:
                onSubscribed();
              case RealtimeSubscribeStatus.channelError:
              case RealtimeSubscribeStatus.closed:
              case RealtimeSubscribeStatus.timedOut:
                if (error != null) {
                  onError(error);
                } else {
                  onError(StateError('Thread realtime subscription failed.'));
                }
            }
          });
    return channel;
  }

  @override
  Future<void> removeChannel(RealtimeChannel channel) {
    return _client.removeChannel(channel);
  }

  @override
  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String body,
  }) async {
    final thread = await _client
        .from('conversations')
        .select('listing_id, buyer_id, seller_id')
        .eq('id', threadId)
        .single();
    await _client.from('messages').insert(<String, dynamic>{
      'conversation_id': threadId,
      'sender_id': senderId,
      'content': body,
    });
    await _client
        .from('conversations')
        .update(<String, dynamic>{
          'last_message_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', threadId);
    final recipientId = senderId == (thread['buyer_id'] as String? ?? '')
        ? (thread['seller_id'] as String? ?? '')
        : (thread['buyer_id'] as String? ?? '');
    if (recipientId.isNotEmpty) {
      await _client.from('notifications').insert(<String, dynamic>{
        'user_id': recipientId,
        'type': 'message_received',
        'data': <String, dynamic>{
          'conversation_id': threadId,
          'listing_id': thread['listing_id'],
          'deep_link': '/messages/thread/$threadId',
        },
      });
    }
  }

  ConversationMessage _messageFromRow(Map<String, dynamic> row) {
    return ConversationMessage(
      id: row['id'] as String? ?? '',
      threadId: row['conversation_id'] as String? ?? '',
      body: row['content'] as String? ?? '',
      senderId: row['sender_id'] as String? ?? '',
      createdAt:
          DateTime.tryParse(
            row['created_at'] as String? ?? '',
          )?.toLocal() ??
          DateTime.now(),
    );
  }
}
