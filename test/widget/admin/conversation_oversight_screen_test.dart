import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/admin/data/conversation_oversight_repository.dart';
import 'package:qitak_app/features/admin/domain/conversation_oversight_case.dart';
import 'package:qitak_app/features/admin/presentation/conversation_oversight_screen.dart';
import 'package:qitak_app/features/messaging/domain/conversation_message.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets(
    'conversation oversight screen uses the repository contract for loading and notes',
    (tester) async {
      final repository = _FakeConversationOversightRepository();
      final scope = await buildTestScope(
        const TestMaterialShell(
          child: Scaffold(
            body: ConversationOversightScreen(conversationId: 'thread-1'),
          ),
        ),
        overrides: [
          conversationOversightRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('admin-purpose-note')),
        'Investigating dispute timeline',
      );
      await tester.tap(find.byKey(const Key('admin-purpose-select')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dispute review').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('admin-purpose-confirm')));
      await tester.pumpAndSettle();

      expect(repository.loadRequests, hasLength(1));
      expect(repository.loadRequests.single.threadId, 'thread-1');
      expect(repository.loadRequests.single.purpose, 'dispute_review');
      expect(
        repository.loadRequests.single.note,
        'Investigating dispute timeline',
      );
      expect(find.text('Buyer: Buyer One'), findsOneWidget);
      expect(find.text('Seller: Seller One'), findsOneWidget);
      expect(find.text('Where is the alternator?'), findsOneWidget);

      await tester.ensureVisible(find.text('Attach case note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Attach case note'));
      await tester.pumpAndSettle();

      expect(repository.noteRequests, hasLength(1));
      expect(repository.noteRequests.single.threadId, 'thread-1');
      expect(repository.noteRequests.single.purpose, 'dispute_review');
      expect(
        repository.noteRequests.single.note,
        'Investigating dispute timeline',
      );
    },
  );
}

class _FakeConversationOversightRepository
    implements ConversationOversightRepository {
  final List<_LoadCaseRequest> loadRequests = <_LoadCaseRequest>[];
  final List<_AttachNoteRequest> noteRequests = <_AttachNoteRequest>[];

  @override
  Future<ConversationOversightCase> loadCase({
    required String threadId,
    required String purpose,
    String? note,
  }) async {
    loadRequests.add(
      _LoadCaseRequest(threadId: threadId, purpose: purpose, note: note),
    );
    return ConversationOversightCase(
      threadId: threadId,
      listingId: 'listing-1',
      listingTitle: 'Alternator',
      buyerUserId: 'buyer-1',
      sellerUserId: 'seller-1',
      buyerName: 'Buyer One',
      sellerName: 'Seller One',
      messages: [
        ConversationMessage(
          id: 'message-1',
          threadId: threadId,
          body: 'Where is the alternator?',
          senderId: 'buyer-1',
          createdAt: DateTime(2026, 6, 4, 9, 30),
        ),
      ],
      transactionId: 'deal-1',
      reportId: 'report-1',
      disputeId: 'dispute-1',
    );
  }

  @override
  Future<void> attachNote({
    required String threadId,
    required String purpose,
    required String note,
  }) async {
    noteRequests.add(
      _AttachNoteRequest(threadId: threadId, purpose: purpose, note: note),
    );
  }
}

class _LoadCaseRequest {
  const _LoadCaseRequest({
    required this.threadId,
    required this.purpose,
    required this.note,
  });

  final String threadId;
  final String purpose;
  final String? note;
}

class _AttachNoteRequest {
  const _AttachNoteRequest({
    required this.threadId,
    required this.purpose,
    required this.note,
  });

  final String threadId;
  final String purpose;
  final String note;
}
