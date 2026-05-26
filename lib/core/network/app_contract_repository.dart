import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDomainCode {
  const AppDomainCode({
    required this.domainKey,
    required this.code,
    required this.active,
    required this.sortOrder,
    this.labelKey,
  });

  final String domainKey;
  final String code;
  final bool active;
  final int sortOrder;
  final String? labelKey;
}

class AppPolicyOption {
  const AppPolicyOption({
    required this.policyType,
    required this.code,
    required this.labelKey,
    required this.active,
    required this.sortOrder,
  });

  final String policyType;
  final String code;
  final String labelKey;
  final bool active;
  final int sortOrder;
}

class AppContractRepository {
  AppContractRepository(this._client, this._prefs);

  final SupabaseClient _client;
  final SharedPreferences _prefs;
  static const kContractCacheTtl = Duration(hours: 24);

  static final Map<String, List<AppDomainCode>> _domainCache =
      <String, List<AppDomainCode>>{};
  static final Map<String, List<AppPolicyOption>> _policyCache =
      <String, List<AppPolicyOption>>{};

  Future<List<AppDomainCode>> fetchDomainContract(String domainKey) async {
    final cached = _domainCache[domainKey];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final fromPrefs = _readDomainFromPrefs(domainKey);
    if (fromPrefs != null && fromPrefs.isNotEmpty) {
      _domainCache[domainKey] = fromPrefs;
      return fromPrefs;
    }

    late final List<dynamic> rows;
    try {
      rows = await _client.rpc<List<dynamic>>(
        'get_app_domain_contracts',
        params: <String, dynamic>{'p_domain_key': domainKey},
      );
    } on Object {
      throw AppException.fromCode(AppErrorCode.contractUnavailable);
    }
    final contracts =
        rows
            .whereType<Map<String, dynamic>>()
            .map(
              (row) => AppDomainCode(
                domainKey: row['domain_key'] as String? ?? domainKey,
                code: row['code'] as String? ?? '',
                active: row['is_active'] as bool? ?? true,
                sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
                labelKey: row['label_key'] as String?,
              ),
            )
            .where((row) => row.code.isNotEmpty && row.active)
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (contracts.isEmpty) {
      throw AppException.fromCode(AppErrorCode.contractUnavailable);
    }
    _domainCache[domainKey] = contracts;
    _writeDomainToPrefs(domainKey, contracts);
    return contracts;
  }

  Future<List<String>> fetchDomainCodes(String domainKey) async {
    final contracts = await fetchDomainContract(domainKey);
    return contracts.map((row) => row.code).toList(growable: false);
  }

  Future<List<AppPolicyOption>> fetchPolicyOptions(String policyType) async {
    final cached = _policyCache[policyType];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final fromPrefs = _readPolicyFromPrefs(policyType);
    if (fromPrefs != null && fromPrefs.isNotEmpty) {
      _policyCache[policyType] = fromPrefs;
      return fromPrefs;
    }

    late final List<dynamic> rows;
    try {
      rows = await _client.rpc<List<dynamic>>(
        'get_app_policy_contracts',
        params: <String, dynamic>{'p_policy_type': policyType},
      );
    } on Object {
      throw AppException.fromCode(AppErrorCode.contractUnavailable);
    }
    final options =
        rows
            .whereType<Map<String, dynamic>>()
            .map(
              (row) => AppPolicyOption(
                policyType: row['policy_type'] as String? ?? '',
                code: row['code'] as String? ?? '',
                labelKey: row['label_key'] as String? ?? '',
                active: row['is_active'] as bool? ?? true,
                sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
              ),
            )
            .where((option) => option.code.isNotEmpty && option.active)
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (options.isEmpty) {
      throw AppException.fromCode(AppErrorCode.contractUnavailable);
    }
    _policyCache[policyType] = options;
    _writePolicyToPrefs(policyType, options);
    return options;
  }

  Future<void> warmAll(List<String> domainKeys) async {
    await Future.wait(
      domainKeys.map((key) async {
        try {
          await fetchDomainCodes(key);
        } on Object {
          // Best-effort warmup; ignore per-domain failures.
        }
      }),
    );
  }

  List<AppDomainCode>? _readDomainFromPrefs(String key) {
    final cached = _readList('contract_cache_$key', 'contract_cache_${key}_ts');
    if (cached == null) {
      return null;
    }
    return cached
        .whereType<Map<String, dynamic>>()
        .map(
          (row) => AppDomainCode(
            domainKey: row['domain_key'] as String? ?? key,
            code: row['code'] as String? ?? '',
            active: row['is_active'] as bool? ?? true,
            sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
            labelKey: row['label_key'] as String?,
          ),
        )
        .where((row) => row.code.isNotEmpty && row.active)
        .toList(growable: false);
  }

  List<AppPolicyOption>? _readPolicyFromPrefs(String key) {
    final cached = _readList('contract_cache_$key', 'contract_cache_${key}_ts');
    if (cached == null) {
      return null;
    }
    return cached
        .whereType<Map<String, dynamic>>()
        .map(
          (row) => AppPolicyOption(
            policyType: row['policy_type'] as String? ?? key,
            code: row['code'] as String? ?? '',
            labelKey: row['label_key'] as String? ?? '',
            active: row['is_active'] as bool? ?? true,
            sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
          ),
        )
        .where((row) => row.code.isNotEmpty && row.active)
        .toList(growable: false);
  }

  List<dynamic>? _readList(String dataKey, String timestampKey) {
    final tsRaw = _prefs.getInt(timestampKey);
    if (tsRaw == null) {
      return null;
    }
    final ts = DateTime.fromMillisecondsSinceEpoch(tsRaw);
    if (DateTime.now().difference(ts) > kContractCacheTtl) {
      return null;
    }
    final json = _prefs.getString(dataKey);
    if (json == null || json.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded;
    }
    return null;
  }

  void _writeDomainToPrefs(String key, List<AppDomainCode> entries) {
    final rows = entries
        .map(
          (entry) => <String, dynamic>{
            'domain_key': entry.domainKey,
            'code': entry.code,
            'is_active': entry.active,
            'sort_order': entry.sortOrder,
            'label_key': entry.labelKey,
          },
        )
        .toList(growable: false);
    _writeList('contract_cache_$key', 'contract_cache_${key}_ts', rows);
  }

  void _writePolicyToPrefs(String key, List<AppPolicyOption> entries) {
    final rows = entries
        .map(
          (entry) => <String, dynamic>{
            'policy_type': entry.policyType,
            'code': entry.code,
            'label_key': entry.labelKey,
            'is_active': entry.active,
            'sort_order': entry.sortOrder,
          },
        )
        .toList(growable: false);
    _writeList('contract_cache_$key', 'contract_cache_${key}_ts', rows);
  }

  void _writeList(String dataKey, String timestampKey, List<dynamic> data) {
    unawaited(_prefs.setString(dataKey, jsonEncode(data)));
    unawaited(
      _prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch),
    );
  }
}

final appContractRepositoryProvider = Provider<AppContractRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  if (client == null) {
    throw StateError('Supabase client is required for app contracts.');
  }
  return AppContractRepository(client, prefs);
});
