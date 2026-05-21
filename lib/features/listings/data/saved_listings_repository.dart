import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SavedListingsRepository {
  const SavedListingsRepository();

  Future<Set<String>> listSavedListingIds(String userId);

  Future<void> saveListing({
    required String userId,
    required String listingId,
  });

  Future<void> removeSavedListing({
    required String userId,
    required String listingId,
  });
}

final savedListingsRepositoryProvider = Provider<SavedListingsRepository>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is required for saved listings.');
  }
  return SupabaseSavedListingsRepository(client);
});

class LocalSavedListingsRepository implements SavedListingsRepository {
  LocalSavedListingsRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _keyPrefix = 'qitak.saved.listings';

  @override
  Future<Set<String>> listSavedListingIds(String userId) async {
    return _prefs.getStringList(_keyFor(userId))?.toSet() ?? const <String>{};
  }

  @override
  Future<void> removeSavedListing({
    required String userId,
    required String listingId,
  }) async {
    final next = await listSavedListingIds(userId)
      ..remove(listingId);
    await _prefs.setStringList(_keyFor(userId), next.toList(growable: false));
  }

  @override
  Future<void> saveListing({
    required String userId,
    required String listingId,
  }) async {
    final next = await listSavedListingIds(userId)
      ..add(listingId);
    await _prefs.setStringList(_keyFor(userId), next.toList(growable: false));
  }

  String _keyFor(String userId) => '$_keyPrefix.$userId';
}

class SupabaseSavedListingsRepository implements SavedListingsRepository {
  SupabaseSavedListingsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Set<String>> listSavedListingIds(String userId) async {
    final rows = await _client
        .from('saved_listings')
        .select('listing_id')
        .eq('user_id', userId);
    return rows
        .whereType<Map<String, dynamic>>()
        .map((row) => row['listing_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  @override
  Future<void> removeSavedListing({
    required String userId,
    required String listingId,
  }) {
    return _client
        .from('saved_listings')
        .delete()
        .eq('user_id', userId)
        .eq('listing_id', listingId);
  }

  @override
  Future<void> saveListing({
    required String userId,
    required String listingId,
  }) {
    return _client.from('saved_listings').upsert(<String, dynamic>{
      'user_id': userId,
      'listing_id': listingId,
    });
  }
}

class SavedListingIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final userId = ref.watch(authSessionProvider).profile?.id;
    if (userId == null) {
      return const <String>{};
    }
    return ref
        .read(savedListingsRepositoryProvider)
        .listSavedListingIds(userId);
  }

  Future<void> toggle(String listingId) async {
    final userId = ref.read(authSessionProvider).profile?.id;
    if (userId == null) {
      return;
    }

    final previous = state.maybeWhen(
      data: (value) => value,
      orElse: () => const <String>{},
    );
    final next = Set<String>.from(previous);
    final repository = ref.read(savedListingsRepositoryProvider);

    try {
      if (!next.add(listingId)) {
        next.remove(listingId);
        await repository.removeSavedListing(
          userId: userId,
          listingId: listingId,
        );
      } else {
        await repository.saveListing(userId: userId, listingId: listingId);
      }
      state = AsyncData(next);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(previous);
    }
  }

  Future<void> remove(String listingId) async {
    final userId = ref.read(authSessionProvider).profile?.id;
    final previous = state.maybeWhen(
      data: (value) => value,
      orElse: () => const <String>{},
    );
    if (userId == null || !previous.contains(listingId)) {
      return;
    }

    final next = Set<String>.from(previous)..remove(listingId);
    state = AsyncData(next);
    try {
      await ref
          .read(savedListingsRepositoryProvider)
          .removeSavedListing(userId: userId, listingId: listingId);
      state = AsyncData(next);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(previous);
    }
  }
}
