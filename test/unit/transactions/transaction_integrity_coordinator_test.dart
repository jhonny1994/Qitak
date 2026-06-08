import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';
import 'package:qitak_app/features/transactions/data/dispute_repository.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'payment proof cleanup runs when persistence fails after upload',
    () async {
      final events = <String>[];

      await expectLater(
        () => const PaymentProofWriteCoordinator().execute<void>(
          uploadProof: () async {
            events.add('upload');
          },
          persistProof: () async {
            events.add('persist');
            throw const PostgrestException(
              message: 'deal update failed',
              code: '23505',
            );
          },
          rollbackUpload: () async {
            events.add('rollback');
          },
        ),
        throwsA(isA<PostgrestException>()),
      );

      expect(events, <String>['upload', 'persist', 'rollback']);
    },
  );

  test(
    'dispute cleanup removes draft state when evidence persistence fails',
    () async {
      final events = <String>[];
      final evidence = ListingMediaSelection(
        fileName: 'proof.png',
        mimeType: 'image/png',
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
      );

      await expectLater(
        () => const DisputeSubmissionCoordinator().execute<String>(
          evidence: <ListingMediaSelection>[evidence],
          createDraft: () async {
            events.add('create');
            return 'dispute-1';
          },
          uploadEvidence: (disputeId, index, item) async {
            events.add('upload:$index');
            return '$disputeId/$index-${item.fileName}';
          },
          persistEvidence: (disputeId, storagePath) async {
            events.add('persist:$storagePath');
            throw const PostgrestException(
              message: 'evidence insert failed',
              code: '23505',
            );
          },
          finish: (disputeId) async {
            events.add('finish');
            return disputeId;
          },
          rollback: (disputeId, uploadedPaths) async {
            events.add('rollback:$disputeId:${uploadedPaths.join(",")}');
          },
        ),
        throwsA(isA<PostgrestException>()),
      );

      expect(events, <String>[
        'create',
        'upload:0',
        'persist:dispute-1/0-proof.png',
        'rollback:dispute-1:dispute-1/0-proof.png',
      ]);
    },
  );
}
