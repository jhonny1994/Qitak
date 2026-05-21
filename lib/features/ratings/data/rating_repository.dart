import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RatingRepository {
  const RatingRepository();

  bool get isLocal;

  Future<void> submitRating({
    required String transactionId,
    required String fromUserId,
    required String toUserId,
    required int score,
  });
}

final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is required for ratings.');
  }
  return SupabaseRatingRepository(client);
});

class LocalRatingRepository implements RatingRepository {
  static final Set<String> _submittedKeys = <String>{};

  static void resetForTest() {
    _submittedKeys.clear();
  }

  @override
  bool get isLocal => true;

  @override
  Future<void> submitRating({
    required String transactionId,
    required String fromUserId,
    required String toUserId,
    required int score,
  }) async {
    if (score < 1 || score > 5) {
      throw ArgumentError.value(
        score,
        'score',
        'Score must be between 1 and 5.',
      );
    }
    final key = '$transactionId|$fromUserId';
    if (_submittedKeys.contains(key)) {
      throw StateError('Rating already submitted for this transaction.');
    }
    _submittedKeys.add(key);
  }
}

class SupabaseRatingRepository implements RatingRepository {
  SupabaseRatingRepository(this._client);

  final SupabaseClient _client;

  @override
  bool get isLocal => false;

  @override
  Future<void> submitRating({
    required String transactionId,
    required String fromUserId,
    required String toUserId,
    required int score,
  }) async {
    final seller = await _client
        .from('sellers')
        .select('id')
        .eq('user_id', toUserId)
        .single();
    await _client.from('seller_reviews').insert(<String, dynamic>{
      'deal_id': transactionId,
      'buyer_id': fromUserId,
      'seller_id': seller['id'],
      'rating': score,
    });
  }
}
