import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';

void main() {
  test('creates one open intent per listing and buyer', () async {
    final repo = LocalTransactionRepository();

    await repo.createIntent(
      listingId: 'listing-1',
      buyerUserId: 'buyer-1',
      sellerUserId: 'seller-1',
    );

    expect(
      () => repo.createIntent(
        listingId: 'listing-1',
        buyerUserId: 'buyer-1',
        sellerUserId: 'seller-1',
      ),
      throwsA(isA<AppException>()),
    );
  });

  test('denies invalid transition by role', () async {
    final repo = LocalTransactionRepository();
    final tx = await repo.createIntent(
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
}
