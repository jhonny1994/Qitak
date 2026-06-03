import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/support/data/support_repository.dart';

void main() {
  const seedProfile = AccountProfile(
    id: 'user-1',
    fullName: 'Support Buyer',
    email: 'buyer@example.com',
    phone: '+213555000111',
    role: AccountRole.buyer,
    language: 'en',
    isActive: true,
  );

  setUp(LocalSupportRepository.resetForTest);

  test('creates authenticated support tickets as open support reports', () async {
    final repo = LocalSupportRepository(seedProfile);

    final ticket = await repo.createTicket(
      reason: 'payment_issue',
      description:
          'Buyer submitted CCP proof but seller still cannot confirm.',
    );

    expect(ticket.userId, seedProfile.id);
    expect(ticket.reason, 'payment_issue');
    expect(ticket.description, contains('CCP proof'));
    expect(ticket.status, 'open');
  });

  test('lists only support tickets for the requested reporter', () async {
    const otherProfile = AccountProfile(
      id: 'user-2',
      fullName: 'Other Support Buyer',
      email: 'other@example.com',
      phone: '+213555000222',
      role: AccountRole.buyer,
      language: 'en',
      isActive: true,
    );
    final repo = LocalSupportRepository(seedProfile);
    final otherRepo = LocalSupportRepository(otherProfile);

    await otherRepo.createTicket(
      reason: 'technical_issue',
      description: 'A different user ticket should not leak.',
    );
    final first = await repo.createTicket(
      reason: 'account_access',
      description: 'First ticket.',
    );
    final second = await repo.createTicket(
      reason: 'seller_issue',
      description: 'Second ticket.',
    );

    final tickets = await repo.listTickets();

    expect(tickets.map((ticket) => ticket.id), <String>[second.id, first.id]);
    expect(tickets.every((ticket) => ticket.userId == seedProfile.id), isTrue);
  });
}
