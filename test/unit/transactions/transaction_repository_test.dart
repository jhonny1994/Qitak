import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';

void main() {
  test('creates one open request per listing and buyer', () async {
    final repo = LocalTransactionRepository();

    await repo.createRequest(
      listingId: 'listing-1',
      buyerUserId: 'buyer-1',
      sellerUserId: 'seller-1',
    );

    expect(
      () => repo.createRequest(
        listingId: 'listing-1',
        buyerUserId: 'buyer-1',
        sellerUserId: 'seller-1',
      ),
      throwsA(isA<AppException>()),
    );
  });

  test('denies invalid transition by role', () async {
    final repo = LocalTransactionRepository();
    final tx = await repo.createRequest(
      listingId: 'listing-2',
      buyerUserId: 'buyer-2',
      sellerUserId: 'seller-2',
    );

    expect(
      () => repo.transition(
        transactionId: tx.id,
        actorUserId: 'buyer-2',
        nextState: TransactionState.sellerConfirmed,
      ),
      throwsA(isA<AppException>()),
    );
  });

  test(
    'cash deals complete only after buyer selects cash and seller confirms',
    () async {
      final repo = LocalTransactionRepository();
      final tx = await repo.createRequest(
        listingId: 'listing-3',
        buyerUserId: 'buyer-3',
        sellerUserId: 'seller-3',
      );

      await repo.transition(
        transactionId: tx.id,
        actorUserId: 'seller-3',
        nextState: TransactionState.sellerConfirmed,
      );
      await repo.selectPaymentMethod(
        transactionId: tx.id,
        actorUserId: 'buyer-3',
        paymentMethod: TransactionPaymentMethod.cash,
      );

      expect(
        () => repo.transition(
          transactionId: tx.id,
          actorUserId: 'buyer-3',
          nextState: TransactionState.completed,
        ),
        throwsA(isA<AppException>()),
      );

      final completed = await repo.transition(
        transactionId: tx.id,
        actorUserId: 'seller-3',
        nextState: TransactionState.completed,
      );
      expect(completed.state, TransactionState.completed);
    },
  );

  test(
    'proof-based deals require seller confirmation before buyer completion',
    () async {
      final repo = LocalTransactionRepository();
      final tx = await repo.createRequest(
        listingId: 'listing-4',
        buyerUserId: 'buyer-4',
        sellerUserId: 'seller-4',
      );

      await repo.transition(
        transactionId: tx.id,
        actorUserId: 'seller-4',
        nextState: TransactionState.sellerConfirmed,
      );
      await repo.selectPaymentMethod(
        transactionId: tx.id,
        actorUserId: 'buyer-4',
        paymentMethod: TransactionPaymentMethod.ccp,
      );
      await repo.submitPaymentProof(
        transactionId: tx.id,
        actorUserId: 'buyer-4',
        proof: ListingMediaSelection(
          fileName: 'proof.jpg',
          mimeType: 'image/jpeg',
          bytes: Uint8List.fromList(<int>[1, 2, 3]),
        ),
      );

      expect(
        () => repo.transition(
          transactionId: tx.id,
          actorUserId: 'buyer-4',
          nextState: TransactionState.completed,
        ),
        throwsA(isA<AppException>()),
      );

      final confirmed = await repo.transition(
        transactionId: tx.id,
        actorUserId: 'seller-4',
        nextState: TransactionState.paymentConfirmed,
      );
      expect(confirmed.state, TransactionState.paymentConfirmed);

      final completed = await repo.transition(
        transactionId: tx.id,
        actorUserId: 'buyer-4',
        nextState: TransactionState.completed,
      );
      expect(completed.state, TransactionState.completed);
    },
  );

  test(
    'ratings require a real completed transaction with matching participants',
    () async {
      final repo = LocalTransactionRepository();
      final tx = await repo.createRequest(
        listingId: 'listing-5',
        buyerUserId: 'buyer-5',
        sellerUserId: 'seller-5',
      );

      expect(
        await repo.canSubmitRating(
          transactionId: 'missing',
          fromUserId: 'buyer-5',
          toUserId: 'seller-5',
        ),
        isFalse,
      );
      expect(
        await repo.canSubmitRating(
          transactionId: tx.id,
          fromUserId: 'buyer-5',
          toUserId: 'seller-5',
        ),
        isFalse,
      );

      await repo.transition(
        transactionId: tx.id,
        actorUserId: 'seller-5',
        nextState: TransactionState.sellerConfirmed,
      );
      await repo.selectPaymentMethod(
        transactionId: tx.id,
        actorUserId: 'buyer-5',
        paymentMethod: TransactionPaymentMethod.cash,
      );
      await repo.transition(
        transactionId: tx.id,
        actorUserId: 'seller-5',
        nextState: TransactionState.completed,
      );

      expect(
        await repo.canSubmitRating(
          transactionId: tx.id,
          fromUserId: 'buyer-5',
          toUserId: 'seller-5',
        ),
        isTrue,
      );
      expect(
        await repo.canSubmitRating(
          transactionId: tx.id,
          fromUserId: 'admin-5',
          toUserId: 'seller-5',
        ),
        isFalse,
      );
    },
  );
}
