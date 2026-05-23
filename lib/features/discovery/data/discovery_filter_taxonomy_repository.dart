import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/discovery/domain/discovery_filter_taxonomy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Concrete implementations split production Supabase reads from local test
// taxonomy loading, so the shared interface is intentional here.
// ignore: one_member_abstracts
abstract class DiscoveryFilterTaxonomyRepository {
  const DiscoveryFilterTaxonomyRepository();

  Future<DiscoveryFilterTaxonomy> load();
}

final discoveryFilterTaxonomyRepositoryProvider =
    Provider<DiscoveryFilterTaxonomyRepository>((ref) {
      final client = ref.watch(supabaseClientProvider);
      if (client == null) {
        throw StateError('Supabase client is required for filter taxonomy.');
      }
      return SupabaseDiscoveryFilterTaxonomyRepository(client);
    });

class SupabaseDiscoveryFilterTaxonomyRepository
    extends DiscoveryFilterTaxonomyRepository {
  const SupabaseDiscoveryFilterTaxonomyRepository(this._client);

  final SupabaseClient _client;
  static const _pageSize = 1000;

  @override
  Future<DiscoveryFilterTaxonomy> load() async {
    final results = await Future.wait([
      _client
          .from('part_categories')
          .select('id, slug, risk_level, policy, sort_order')
          .eq('is_active', true)
          .order('sort_order'),
      _client.from('wilayas').select('id, name, arabic_name').order('id'),
      _selectAllRows(
        (from, start, end) => from
            .select('id, wilaya_id, name, arabic_name')
            .order('wilaya_id')
            .order('name')
            .range(start, end),
        table: 'communes',
      ),
      _client.from('car_makes').select('id, name').order('name'),
      _selectAllRows(
        (from, start, end) => from
            .select('make_id, base_model, year')
            .order('make_id')
            .order('base_model')
            .order('year')
            .range(start, end),
        table: 'car_models',
      ),
    ]);

    final categoryRows = results[0];
    final wilayaRows = results[1];
    final communeRows = results[2];
    final makeRows = results[3];
    final modelRows = results[4];

    final communesByWilaya = <String, List<CommuneOption>>{};
    for (final row in communeRows.whereType<Map<String, dynamic>>()) {
      final wilayaId = row['wilaya_id']?.toString() ?? '';
      communesByWilaya
          .putIfAbsent(wilayaId, () => <CommuneOption>[])
          .add(
            CommuneOption(
              id: row['id'].toString(),
              name: row['name'] as String? ?? '',
              arabicName: row['arabic_name'] as String? ?? '',
            ),
          );
    }

    final makeNamesById = <String, String>{};
    for (final row in makeRows.whereType<Map<String, dynamic>>()) {
      makeNamesById[row['id'].toString()] = row['name'] as String? ?? '';
    }

    final makeMap = <String, Map<String, Set<int>>>{};
    for (final row in modelRows.whereType<Map<String, dynamic>>()) {
      final makeId = row['make_id']?.toString() ?? '';
      final makeName = makeNamesById[makeId] ?? '';
      final baseModel = (row['base_model'] as String? ?? '').trim();
      final year = (row['year'] as num?)?.toInt();
      if (makeName.isEmpty || baseModel.isEmpty || year == null) {
        continue;
      }

      makeMap
          .putIfAbsent(makeName, () => <String, Set<int>>{})
          .putIfAbsent(baseModel, () => <int>{})
          .add(year);
    }

    return DiscoveryFilterTaxonomy(
      categories: categoryRows
          .whereType<Map<String, dynamic>>()
          .map(
            (row) => DiscoveryCategoryOption(
              id: row['id'].toString(),
              slug: row['slug'] as String? ?? '',
              riskLevel: row['risk_level'] as String? ?? 'green',
              requiresReview:
                  ((row['policy'] as Map?)?.cast<String, dynamic>() ??
                          const <String, dynamic>{})['requires_review']
                      as bool? ??
                  false,
              minPhotos:
                  ((((row['policy'] as Map?)?.cast<String, dynamic>() ??
                              const <String, dynamic>{})['min_photos'])
                          as num?)
                      ?.toInt() ??
                  2,
            ),
          )
          .toList(growable: false),
      wilayas: wilayaRows
          .whereType<Map<String, dynamic>>()
          .map(
            (row) => WilayaOption(
              id: row['id'].toString(),
              name: row['name'] as String? ?? '',
              arabicName: row['arabic_name'] as String? ?? '',
              communes:
                  communesByWilaya[row['id'].toString()] ??
                  const <CommuneOption>[],
            ),
          )
          .toList(growable: false),
      makes: _buildMakeOptions(makeMap),
    );
  }

  Future<List<dynamic>> _selectAllRows(
    PostgrestTransformBuilder<List<dynamic>> Function(
      PostgrestQueryBuilder<dynamic> from,
      int start,
      int end,
    )
    queryBuilder, {
    required String table,
  }) async {
    final rows = <dynamic>[];
    var start = 0;

    while (true) {
      final batch = await queryBuilder(
        _client.from(table),
        start,
        start + _pageSize - 1,
      );
      rows.addAll(batch);
      if (batch.length < _pageSize) {
        return rows;
      }
      start += _pageSize;
    }
  }
}

List<CarMakeOption> _buildMakeOptions(
  Map<String, Map<String, Set<int>>> makeMap,
) {
  final makes = makeMap.entries.map((entry) {
    final models =
        entry.value.entries
            .map((modelEntry) {
              final years = modelEntry.value.toList()..sort();
              return CarModelOption(name: modelEntry.key, years: years);
            })
            .toList(growable: false)
          ..sort((a, b) => a.name.compareTo(b.name));

    return CarMakeOption(id: entry.key, name: entry.key, models: models);
  }).toList()..sort((a, b) => a.name.compareTo(b.name));

  return makes;
}
