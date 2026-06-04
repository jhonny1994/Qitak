import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';
import 'package:qitak_app/features/transactions/data/dispute_repository.dart';

void main() {
  setUp(LocalDisputeRepository.resetForTest);

  test('submitted local disputes persist with evidence previews', () async {
    const repository = LocalDisputeRepository();

    final dispute = await repository.submit(
      transactionId: 'deal-1',
      createdByUserId: 'buyer-1',
      reason: 'wrong_part',
      description: 'The delivered part does not match the listing details.',
      evidence: [
        ListingMediaSelection(
          fileName: 'proof.png',
          mimeType: 'image/png',
          bytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
        ),
      ],
    );

    expect(dispute.status, 'open');
    expect(dispute.evidence, hasLength(1));
    expect(dispute.evidence.single.storagePath, contains('proof.png'));
    expect(
      dispute.evidence.single.previewUrl,
      startsWith('data:image/png;base64,'),
    );

    final openDisputes = await repository.listOpenDisputes();
    expect(openDisputes.map((item) => item.id), <String>[dispute.id]);

    final fetched = await repository.fetchById(dispute.id);
    expect(fetched, isNotNull);
    expect(fetched!.description, contains('does not match'));
  });

  test(
    'resolved local disputes leave the admin queue with final status',
    () async {
      const repository = LocalDisputeRepository();
      final dispute = await repository.submit(
        transactionId: 'deal-2',
        createdByUserId: 'buyer-2',
        reason: 'condition',
        description:
            'The condition shown in the listing is not what was handed off.',
      );

      await repository.resolve(
        disputeId: dispute.id,
        decision: 'seller',
        reasonCode: 'insufficient_evidence',
        outcomeAction: 'warn',
      );

      expect(await repository.listOpenDisputes(), isEmpty);
      final fetched = await repository.fetchById(dispute.id);
      expect(fetched, isNotNull);
      expect(fetched!.status, 'resolved_seller');
    },
  );
}
