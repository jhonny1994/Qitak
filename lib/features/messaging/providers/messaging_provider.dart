import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';
import 'package:qitak_app/features/messaging/domain/conversation_message.dart';
import 'package:qitak_app/features/messaging/domain/conversation_thread_summary.dart';
import 'package:qitak_app/shared/providers/unread_counts_provider.dart';

class MessagingState {
  const MessagingState({
    this.lastError,
  });

  final String? lastError;

  MessagingState copyWith({
    String? lastError,
  }) {
    return MessagingState(
      lastError: lastError,
    );
  }
}

class MessagingOnlineNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  bool get isOnline => state;
  set isOnline(bool value) => state = value;
}

final NotifierProvider<MessagingOnlineNotifier, bool> messagingOnlineProvider =
    NotifierProvider<MessagingOnlineNotifier, bool>(
      MessagingOnlineNotifier.new,
    );

class MessagingNotifier extends Notifier<MessagingState> {
  @override
  MessagingState build() => const MessagingState();

  Future<bool> sendMessage({
    required String threadId,
    required String senderId,
    required String body,
  }) async {
    final isOnline = ref.read(messagingOnlineProvider);
    if (!isOnline) {
      state = state.copyWith(lastError: 'offline');
      return false;
    }
    await ref
        .read(messagingRepositoryProvider)
        .sendMessage(
          threadId: threadId,
          senderId: senderId,
          body: body.trim(),
        );
    ref
      ..invalidate(conversationMessagesProvider(threadId))
      ..invalidate(conversationThreadsProvider);
    state = const MessagingState();
    return true;
  }
}

final messagingProvider = NotifierProvider<MessagingNotifier, MessagingState>(
  MessagingNotifier.new,
);

class ConversationThreadsNotifier
    extends AsyncNotifier<List<ConversationThreadSummary>> {
  Timer? _reconnectTimer;

  @override
  Future<List<ConversationThreadSummary>> build() async {
    ref.onDispose(() => _reconnectTimer?.cancel());

    final userId = ref.watch(authSessionProvider).profile?.id;
    if (userId == null) {
      return const <ConversationThreadSummary>[];
    }

    final repository = ref.read(messagingRepositoryProvider);
    final channels = repository.subscribeToConversationListChanges(
      userId: userId,
      onChange: () async {
        final refreshed = await repository.listThreadsForUser(userId);
        state = AsyncData(refreshed);
      },
      onError: (_) => _scheduleReconnect(),
    );
    ref.onDispose(() {
      for (final channel in channels) {
        unawaited(repository.removeChannel(channel));
      }
    });

    final threads = await repository.listThreadsForUser(userId);
    await repository.markAllMessagesRead(userId);
    unawaited(_refreshUnreadCounts());
    return threads;
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), ref.invalidateSelf);
  }

  Future<void> _refreshUnreadCounts() async {
    await ref.read(unreadCountsProvider.notifier).refresh();
  }
}

final conversationThreadsProvider =
    AsyncNotifierProvider<
      ConversationThreadsNotifier,
      List<ConversationThreadSummary>
    >(
      ConversationThreadsNotifier.new,
    );

class ConversationMessagesNotifier
    extends AsyncNotifier<List<ConversationMessage>> {
  ConversationMessagesNotifier(this.threadId);

  final String threadId;
  Timer? _reconnectTimer;

  @override
  Future<List<ConversationMessage>> build() async {
    ref.onDispose(() => _reconnectTimer?.cancel());

    final userId = ref.watch(authSessionProvider).profile?.id;
    if (userId == null) {
      return const <ConversationMessage>[];
    }

    final repository = ref.read(messagingRepositoryProvider);
    final initial = await repository.listMessages(
      threadId: threadId,
      userId: userId,
    );
    var catchUpCursor = initial.isEmpty
        ? DateTime.now().toUtc()
        : initial.last.createdAt.toUtc();

    if (!repository.isLocal) {
      final channel = repository.subscribeToThreadMessages(
        threadId: threadId,
        onMessage: (message) {
          final current = state.asData?.value ?? const <ConversationMessage>[];
          if (current.any((item) => item.id == message.id)) {
            return;
          }
          final next = [...current, message]
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          catchUpCursor = next.last.createdAt.toUtc();
          state = AsyncData(next);
          unawaited(_handleIncomingMessage(threadId, userId));
        },
        onSubscribed: () async {
          final catchUp = await repository.listMessagesAfter(
            threadId: threadId,
            userId: userId,
            after: catchUpCursor,
          );
          if (catchUp.isEmpty) {
            return;
          }
          final current = state.asData?.value ?? initial;
          final merged = <ConversationMessage>[...current];
          for (final message in catchUp) {
            if (merged.any((item) => item.id == message.id)) {
              continue;
            }
            merged.add(message);
          }
          merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          catchUpCursor = merged.last.createdAt.toUtc();
          state = AsyncData(merged);
          await _handleIncomingMessage(threadId, userId);
        },
        onError: (_) => _scheduleReconnect(),
      );

      ref.onDispose(() {
        unawaited(repository.removeChannel(channel));
      });
    }

    await repository.markThreadMessagesRead(
      threadId: threadId,
      userId: userId,
    );
    unawaited(_refreshUnreadCounts());
    return initial;
  }

  Future<void> _handleIncomingMessage(String threadId, String userId) async {
    await ref
        .read(messagingRepositoryProvider)
        .markThreadMessagesRead(
          threadId: threadId,
          userId: userId,
        );
    ref.invalidate(conversationThreadsProvider);
    await _refreshUnreadCounts();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), ref.invalidateSelf);
  }

  Future<void> _refreshUnreadCounts() async {
    await ref.read(unreadCountsProvider.notifier).refresh();
  }
}

final AsyncNotifierProviderFamily<
  ConversationMessagesNotifier,
  List<ConversationMessage>,
  String
>
conversationMessagesProvider =
    AsyncNotifierProvider.family<
      ConversationMessagesNotifier,
      List<ConversationMessage>,
      String
    >(ConversationMessagesNotifier.new);
