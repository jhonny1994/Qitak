import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/admin/data/admin_reports_repository.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/listings/data/listing_repository.dart';
import 'package:qitak_app/features/listings/data/local_listing_store.dart';
import 'package:qitak_app/features/support/data/support_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const buyerProfile = AccountProfile(
    id: 'buyer-1',
    fullName: 'Buyer One',
    email: 'buyer1@example.com',
    phone: '+213555001001',
    role: AccountRole.buyer,
    language: 'en',
    isActive: true,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    LocalAdminReportsRepository.resetForTest();
  });

  test(
    'support close decisions keep shared dismissed status',
    () async {
      final supportRepository = LocalSupportRepository(buyerProfile);
      const adminRepository = LocalAdminReportsRepository();

      final ticket = await supportRepository.createTicket(
        reason: 'payment_issue',
        description:
            'Buyer uploaded a BaridiMob proof and still needs support review.',
      );

      final openReports = await adminRepository.listOpenReports();
      expect(openReports, hasLength(1));
      expect(openReports.single.id, ticket.id);
      expect(openReports.single.entityType, 'support');
      expect(openReports.single.reporterName, buyerProfile.fullName);
      expect(openReports.single.entityPreview, 'support ticket');

      final detail = await adminRepository.fetchReport(ticket.id);
      expect(detail, isNotNull);
      expect(detail!.reporterHistoryCount, 1);
      expect(detail.entityHistoryCount, 1);

      await adminRepository.resolveReport(
        reportId: ticket.id,
        decision: 'close',
        reasonCode: 'duplicate_ticket',
      );

      expect(await adminRepository.listOpenReports(), isEmpty);
      final tickets = await supportRepository.listTickets();
      expect(tickets.single.status, 'dismissed');
    },
  );

  test(
    'support resolve decisions keep shared actioned status',
    () async {
      final supportRepository = LocalSupportRepository(buyerProfile);
      const adminRepository = LocalAdminReportsRepository();

      final ticket = await supportRepository.createTicket(
        reason: 'technical_issue',
        description:
            'Buyer needs platform help after a technical problem blocked checkout.',
      );

      await adminRepository.resolveReport(
        reportId: ticket.id,
        decision: 'resolve',
        reasonCode: 'verified_and_resolved',
      );

      final tickets = await supportRepository.listTickets();
      expect(tickets.single.status, 'actioned');
    },
  );

  test(
    'unknown local report decisions fail fast',
    () async {
      final supportRepository = LocalSupportRepository(buyerProfile);
      const adminRepository = LocalAdminReportsRepository();

      final ticket = await supportRepository.createTicket(
        reason: 'technical_issue',
        description:
            'Buyer needs platform help after a technical problem blocked checkout.',
      );

      await expectLater(
        adminRepository.resolveReport(
          reportId: ticket.id,
          decision: 'escalate_to_mars',
          reasonCode: 'verified_and_resolved',
        ),
        throwsArgumentError,
      );

      final tickets = await supportRepository.listTickets();
      expect(tickets.single.status, 'open');
    },
  );

  test(
    'listing reports are tracked locally with report detail context',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await LocalListingStore(prefs).append(
        LocalStoredListing(
          id: 'listing-1',
          sellerUserId: 'seller-1',
          sellerName: 'Seller One',
          title: 'Brake pads',
          price: 12000,
          wilayaLabel: 'Algiers',
          communeLabel: 'Bab Ezzouar',
          brandCode: 'renault',
          modelCode: 'symbol',
          year: 2018,
          categoryId: 'brakes',
          condition: 'used',
          description: 'Clean local seed listing.',
          quantity: 1,
          exchangeEnabled: false,
          wilayaCode: '16',
          communeCode: '1605',
          mediaUrls: const <String>[],
          createdAt: DateTime.utc(2026, 6, 4),
          status: 'active',
        ),
      );
      final listingRepository = LocalListingRepository(prefs, buyerProfile);
      const adminRepository = LocalAdminReportsRepository();

      expect(
        await listingRepository.hasUserReportedListing('listing-1'),
        isFalse,
      );

      await listingRepository.reportListing('listing-1', 'spam');

      expect(
        await listingRepository.hasUserReportedListing('listing-1'),
        isTrue,
      );
      final report = (await adminRepository.listOpenReports()).single;
      expect(report.entityType, 'listing');
      expect(report.entityId, 'listing-1');
      expect(report.entityPreview, 'Brake pads');
      expect(report.reason, 'spam');

      final detail = await adminRepository.fetchReport(report.id);
      expect(detail, isNotNull);
      expect(detail!.reporterHistoryCount, 1);
      expect(detail.entityHistoryCount, 1);
    },
  );
}
