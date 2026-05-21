import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/features/ratings/data/rating_repository.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';

class RatingItem {
  const RatingItem({
    required this.transactionId,
    required this.fromUserId,
    required this.toUserId,
    required this.score,
  });

  final String transactionId;
  final String fromUserId;
  final String toUserId;
  final int score;
}

class RatingState {
  const RatingState({this.items = const <RatingItem>[], this.lastError});

  final List<RatingItem> items;
  final String? lastError;

  RatingState copyWith({
    List<RatingItem>? items,
    String? lastError,
  }) {
    return RatingState(
      items: items ?? this.items,
      lastError: lastError,
    );
  }
}

class RatingNotifier extends Notifier<RatingState> {
  @override
  RatingState build() => const RatingState();

  Future<bool> submit({
    required String transactionId,
    required String fromUserId,
    required String toUserId,
    required int score,
  }) async {
    final eligible = await ref
        .read(transactionRepositoryProvider)
        .canSubmitRating(
          transactionId: transactionId,
          fromUserId: fromUserId,
          toUserId: toUserId,
        );
    if (!eligible) {
      state = state.copyWith(lastError: 'ineligible');
      return false;
    }
    final duplicate = state.items.any(
      (item) =>
          item.transactionId == transactionId && item.fromUserId == fromUserId,
    );
    if (duplicate) {
      state = state.copyWith(lastError: 'duplicate');
      return false;
    }
    await ref
        .read(ratingRepositoryProvider)
        .submitRating(
          transactionId: transactionId,
          fromUserId: fromUserId,
          toUserId: toUserId,
          score: score,
        );
    state = state.copyWith(
      items: [
        ...state.items,
        RatingItem(
          transactionId: transactionId,
          fromUserId: fromUserId,
          toUserId: toUserId,
          score: score,
        ),
      ],
    );
    return true;
  }
}

final ratingProvider = NotifierProvider<RatingNotifier, RatingState>(
  RatingNotifier.new,
);
