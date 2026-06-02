import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';

void main() {
  group('SellerVerificationStatus.fromWire', () {
    test('returns the matching enum for every known wire name', () {
      expect(
        SellerVerificationStatus.fromWire('not_started'),
        SellerVerificationStatus.notStarted,
      );
      expect(
        SellerVerificationStatus.fromWire('draft'),
        SellerVerificationStatus.draft,
      );
      expect(
        SellerVerificationStatus.fromWire('submitted'),
        SellerVerificationStatus.submitted,
      );
      expect(
        SellerVerificationStatus.fromWire('needs_more_info'),
        SellerVerificationStatus.needsMoreInfo,
      );
      expect(
        SellerVerificationStatus.fromWire('approved'),
        SellerVerificationStatus.approved,
      );
      expect(
        SellerVerificationStatus.fromWire('rejected'),
        SellerVerificationStatus.rejected,
      );
      expect(
        SellerVerificationStatus.fromWire('suspended'),
        SellerVerificationStatus.suspended,
      );
    });

    test('falls back to notStarted when the wire name is null', () {
      expect(
        SellerVerificationStatus.fromWire(null),
        SellerVerificationStatus.notStarted,
      );
    });

    test('falls back to notStarted when the wire name is unknown', () {
      expect(
        SellerVerificationStatus.fromWire('archived'),
        SellerVerificationStatus.notStarted,
      );
      expect(
        SellerVerificationStatus.fromWire(''),
        SellerVerificationStatus.notStarted,
      );
    });
  });

  group('SellerVerificationStatus.wireName', () {
    test('round-trips through fromWire for every enum value', () {
      for (final value in SellerVerificationStatus.values) {
        expect(
          SellerVerificationStatus.fromWire(value.wireName),
          value,
          reason: 'wireName ${value.wireName} did not round-trip',
        );
      }
    });

    test('uses snake_case wire format expected by the Postgres enum', () {
      expect(SellerVerificationStatus.notStarted.wireName, 'not_started');
      expect(SellerVerificationStatus.draft.wireName, 'draft');
      expect(SellerVerificationStatus.submitted.wireName, 'submitted');
      expect(
        SellerVerificationStatus.needsMoreInfo.wireName,
        'needs_more_info',
      );
      expect(SellerVerificationStatus.approved.wireName, 'approved');
      expect(SellerVerificationStatus.rejected.wireName, 'rejected');
      expect(SellerVerificationStatus.suspended.wireName, 'suspended');
    });
  });

  group('SellerApplication getters', () {
    SellerApplication makeApp(SellerVerificationStatus status) =>
        SellerApplication(
          id: 'app-1',
          userId: 'user-1',
          sellerType: 'individual',
          businessName: 'Karim Auto',
          phone: '+213555000111',
          email: 'seller@qitak.test',
          wilayaId: '16',
          communeId: '1601',
          bio: '',
          verificationStatus: status,
        );

    test('isApproved matches only the approved enum value', () {
      expect(makeApp(SellerVerificationStatus.approved).isApproved, isTrue);
      expect(
        makeApp(SellerVerificationStatus.notStarted).isApproved,
        isFalse,
      );
      expect(
        makeApp(SellerVerificationStatus.submitted).isApproved,
        isFalse,
      );
      expect(
        makeApp(SellerVerificationStatus.rejected).isApproved,
        isFalse,
      );
      expect(
        makeApp(SellerVerificationStatus.suspended).isApproved,
        isFalse,
      );
    });

    test('isSubmitted matches only the submitted enum value', () {
      expect(makeApp(SellerVerificationStatus.submitted).isSubmitted, isTrue);
      expect(
        makeApp(SellerVerificationStatus.needsMoreInfo).isSubmitted,
        isFalse,
      );
    });

    test('needsMoreInfo matches only the needsMoreInfo enum value', () {
      expect(
        makeApp(SellerVerificationStatus.needsMoreInfo).needsMoreInfo,
        isTrue,
      );
      expect(
        makeApp(SellerVerificationStatus.approved).needsMoreInfo,
        isFalse,
      );
    });

    test('isRejected matches only the rejected enum value', () {
      expect(makeApp(SellerVerificationStatus.rejected).isRejected, isTrue);
      expect(
        makeApp(SellerVerificationStatus.approved).isRejected,
        isFalse,
      );
    });

    test('isSuspended matches only the suspended enum value', () {
      expect(makeApp(SellerVerificationStatus.suspended).isSuspended, isTrue);
      expect(
        makeApp(SellerVerificationStatus.approved).isSuspended,
        isFalse,
      );
    });
  });
}
