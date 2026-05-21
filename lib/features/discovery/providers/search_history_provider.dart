import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/network/supabase_client_provider.dart';

class SearchHistoryNotifier extends AsyncNotifier<List<String>> {
  static const _storageKey = 'search_history';
  static const _maxItems = 10;

  @override
  Future<List<String>> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const <String>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <String>[];
      }
      return decoded
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .take(_maxItems)
          .toList(growable: false);
    } on FormatException {
      return const <String>[];
    }
  }

  Future<void> add(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return;
    }

    final current = state.asData?.value ?? await future;
    final next = <String>[
      normalized,
      ...current.where(
        (item) => item.toLowerCase() != normalized.toLowerCase(),
      ),
    ];
    final limited = next.take(_maxItems).toList(growable: false);
    await _persist(limited);
    state = AsyncData(limited);
  }

  Future<void> clear() async {
    await _persist(const <String>[]);
    state = const AsyncData(<String>[]);
  }

  Future<void> _persist(List<String> values) {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.setString(_storageKey, jsonEncode(values));
  }
}

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, List<String>>(
      SearchHistoryNotifier.new,
    );
