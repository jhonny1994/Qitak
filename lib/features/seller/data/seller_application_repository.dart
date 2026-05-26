import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SellerApplicationRepository {
  const SellerApplicationRepository();

  Future<SellerApplication?> fetchCurrentForUser(String userId);

  Future<SellerApplication> submitApplication({
    required String userId,
    required SellerApplicationDraft draft,
  });

  Future<List<SellerApplication>> listPendingApplications();

  Future<SellerApplication?> fetchById(String applicationId);

  Future<SellerApplication> updateStatus({
    required String applicationId,
    required String status,
    String? reasonCode,
    String? note,
  });

  Future<List<AppPolicyOption>> fetchPolicyOptions(String policyType);
}

final sellerApplicationRepositoryProvider =
    Provider<SellerApplicationRepository>((ref) {
      final client = ref.watch(supabaseClientProvider);
      final prefs = ref.watch(sharedPreferencesProvider);
      if (client == null) {
        throw StateError(
          'Supabase client is required for seller verification.',
        );
      }
      return SupabaseSellerApplicationRepository(client, prefs);
    });

final currentSellerApplicationProvider = FutureProvider<SellerApplication?>((
  ref,
) async {
  final profile = ref.watch(authSessionProvider).profile;
  if (profile == null) {
    return null;
  }
  return ref
      .read(sellerApplicationRepositoryProvider)
      .fetchCurrentForUser(profile.id);
});

final adminPendingSellerApplicationsProvider =
    FutureProvider<List<SellerApplication>>((ref) {
      return ref
          .read(sellerApplicationRepositoryProvider)
          .listPendingApplications();
    });

class LocalSellerApplicationRepository implements SellerApplicationRepository {
  LocalSellerApplicationRepository(this._prefs, this._ref);

  static const _storageKey = 'qitak.local.seller.applications';
  final SharedPreferences _prefs;
  final Ref _ref;

  List<Map<String, dynamic>> _loadRows() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    return (jsonDecode(raw) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList(growable: true);
  }

  Future<void> _saveRows(List<Map<String, dynamic>> rows) async {
    await _prefs.setString(_storageKey, jsonEncode(rows));
  }

  @override
  Future<SellerApplication?> fetchCurrentForUser(String userId) async {
    final rows = _loadRows();
    final match = rows.cast<Map<String, dynamic>?>().firstWhere(
      (row) => row?['user_id'] == userId,
      orElse: () => null,
    );
    if (match == null) {
      return null;
    }
    return _mapRow(match);
  }

  @override
  Future<SellerApplication?> fetchById(String applicationId) async {
    final rows = _loadRows();
    final match = rows.cast<Map<String, dynamic>?>().firstWhere(
      (row) => row?['id'] == applicationId,
      orElse: () => null,
    );
    if (match == null) {
      return null;
    }
    return _mapRow(match);
  }

  @override
  Future<List<SellerApplication>> listPendingApplications() async {
    final rows = _loadRows();
    return rows
        .map(_mapRow)
        .where(
          (item) =>
              item.verificationStatus == 'submitted' ||
              item.verificationStatus == 'needs_more_info',
        )
        .toList(growable: false);
  }

  @override
  Future<SellerApplication> submitApplication({
    required String userId,
    required SellerApplicationDraft draft,
  }) async {
    final rows = _loadRows();
    final now = DateTime.now().toIso8601String();
    final existingIndex = rows.indexWhere((row) => row['user_id'] == userId);
    final row = <String, dynamic>{
      'id': existingIndex >= 0
          ? rows[existingIndex]['id']
          : 'seller-app-$userId',
      'user_id': userId,
      'seller_type': draft.sellerType,
      'business_name': draft.businessName,
      'phone': draft.phone,
      'wilaya_id': draft.wilayaId,
      'commune_id': draft.communeId,
      'bio': draft.bio,
      'verification_status': 'submitted',
      'review_reason_code': null,
      'review_note': null,
      'submitted_at': now,
    };
    if (existingIndex >= 0) {
      rows[existingIndex] = row;
    } else {
      rows.add(row);
    }
    await _saveRows(rows);
    _ref
      ..invalidate(currentSellerApplicationProvider)
      ..invalidate(adminPendingSellerApplicationsProvider);
    return _mapRow(row);
  }

  @override
  Future<SellerApplication> updateStatus({
    required String applicationId,
    required String status,
    String? reasonCode,
    String? note,
  }) async {
    final rows = _loadRows();
    final index = rows.indexWhere((row) => row['id'] == applicationId);
    if (index < 0) {
      throw AppException.fromCode(AppErrorCode.notFound);
    }
    rows[index] = <String, dynamic>{
      ...rows[index],
      'verification_status': status,
      'review_reason_code': reasonCode,
      'review_note': note,
      'reviewed_at': DateTime.now().toIso8601String(),
    };
    await _saveRows(rows);

    _ref
      ..invalidate(currentSellerApplicationProvider)
      ..invalidate(adminPendingSellerApplicationsProvider);
    return _mapRow(rows[index]);
  }

  @override
  Future<List<AppPolicyOption>> fetchPolicyOptions(String policyType) async {
    if (policyType == 'seller_document_type') {
      return const <AppPolicyOption>[
        AppPolicyOption(
          policyType: 'seller_document_type',
          code: 'government_id_front',
          labelKey: 'sellerDocumentIdFrontLabel',
          active: true,
          sortOrder: 10,
        ),
        AppPolicyOption(
          policyType: 'seller_document_type',
          code: 'government_id_back',
          labelKey: 'sellerDocumentIdBackLabel',
          active: true,
          sortOrder: 20,
        ),
        AppPolicyOption(
          policyType: 'seller_document_type',
          code: 'business_registration',
          labelKey: 'sellerDocumentBusinessRegistrationLabel',
          active: true,
          sortOrder: 30,
        ),
      ];
    }
    if (policyType == 'seller_verification_reason_code') {
      return const <AppPolicyOption>[
        AppPolicyOption(
          policyType: 'seller_verification_reason_code',
          code: 'document_unreadable',
          labelKey: 'adminVerificationReasonUnreadable',
          active: true,
          sortOrder: 10,
        ),
        AppPolicyOption(
          policyType: 'seller_verification_reason_code',
          code: 'identity_mismatch',
          labelKey: 'adminVerificationReasonIdentityMismatch',
          active: true,
          sortOrder: 20,
        ),
        AppPolicyOption(
          policyType: 'seller_verification_reason_code',
          code: 'missing_business_registration',
          labelKey: 'adminVerificationReasonMissingBusinessDocument',
          active: true,
          sortOrder: 30,
        ),
      ];
    }
    return const <AppPolicyOption>[];
  }

  SellerApplication _mapRow(Map<String, dynamic> row) {
    return SellerApplication(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      sellerType: row['seller_type'] as String? ?? 'individual',
      businessName: row['business_name'] as String? ?? '',
      phone: row['phone'] as String? ?? '',
      email: row['email'] as String? ?? '',
      wilayaId: row['wilaya_id'].toString(),
      communeId: row['commune_id'].toString(),
      bio: row['bio'] as String? ?? '',
      verificationStatus: row['verification_status'] as String? ?? 'draft',
      reviewReasonCode: row['review_reason_code'] as String?,
      reviewNote: row['review_note'] as String?,
      submittedAt: row['submitted_at'] == null
          ? null
          : DateTime.tryParse(row['submitted_at'] as String),
      reviewedAt: row['reviewed_at'] == null
          ? null
          : DateTime.tryParse(row['reviewed_at'] as String),
    );
  }
}

class SupabaseSellerApplicationRepository
    implements SellerApplicationRepository {
  SupabaseSellerApplicationRepository(this._client, this._prefs);

  final SupabaseClient _client;
  final SharedPreferences _prefs;
  AppContractRepository get _contracts =>
      AppContractRepository(_client, _prefs);

  @override
  Future<SellerApplication?> fetchCurrentForUser(String userId) async {
    final row = await _client
        .from('sellers')
        .select(
          'id, user_id, seller_type, business_name, bio, wilaya_id, commune_id, '
          'verification_status, created_at, verified_at, review_reason_code, review_note',
        )
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    final profile = await _client
        .from('profiles')
        .select('phone, email')
        .eq('id', userId)
        .maybeSingle();
    final documents = await _fetchDocuments(row['id'] as String);
    return _mapRow(
      row,
      phone: (profile?['phone'] as String?) ?? '',
      email: (profile?['email'] as String?) ?? '',
      documents: documents,
    );
  }

  @override
  Future<SellerApplication?> fetchById(String applicationId) async {
    final row = await _client
        .from('sellers')
        .select(
          'id, user_id, seller_type, business_name, bio, wilaya_id, commune_id, '
          'verification_status, created_at, verified_at, review_reason_code, review_note',
        )
        .eq('id', applicationId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    final profile = await _client
        .from('profiles')
        .select('phone, email')
        .eq('id', row['user_id'] as String)
        .maybeSingle();
    final documents = await _fetchDocuments(row['id'] as String);
    return _mapRow(
      row,
      phone: (profile?['phone'] as String?) ?? '',
      email: (profile?['email'] as String?) ?? '',
      documents: documents,
    );
  }

  @override
  Future<List<SellerApplication>> listPendingApplications() async {
    final rows = await _client
        .from('sellers')
        .select(
          'id, user_id, seller_type, business_name, bio, wilaya_id, commune_id, '
          'verification_status, created_at, verified_at, review_reason_code, review_note',
        )
        .inFilter('verification_status', ['submitted', 'needs_more_info']);
    final data = rows as List<dynamic>;
    final result = <SellerApplication>[];
    for (final raw in data.whereType<Map<String, dynamic>>()) {
      final profile = await _client
          .from('profiles')
          .select('phone, email')
          .eq('id', raw['user_id'] as String)
          .maybeSingle();
      final documents = await _fetchDocuments(raw['id'] as String);
      result.add(
        _mapRow(
          raw,
          phone: (profile?['phone'] as String?) ?? '',
          email: (profile?['email'] as String?) ?? '',
          documents: documents,
        ),
      );
    }
    return result;
  }

  @override
  Future<SellerApplication> submitApplication({
    required String userId,
    required SellerApplicationDraft draft,
  }) async {
    final row = await _client
        .from('sellers')
        .upsert(<String, dynamic>{
          'user_id': userId,
          'seller_type': draft.sellerType,
          'business_name': draft.businessName,
          'bio': draft.bio,
          'wilaya_id': int.parse(draft.wilayaId),
          'commune_id': draft.communeId,
          'policy_accepted_at': draft.policiesAccepted
              ? DateTime.now().toIso8601String()
              : null,
          'verification_status': 'submitted',
        })
        .select(
          'id, user_id, seller_type, business_name, bio, wilaya_id, commune_id, '
          'verification_status, created_at, verified_at, review_reason_code, review_note',
        )
        .single();

    await _syncDocuments(
      sellerId: row['id'] as String,
      userId: userId,
      documents: draft.documents,
    );

    final documents = await _fetchDocuments(row['id'] as String);
    return _mapRow(
      row,
      phone: draft.phone,
      email: _client.auth.currentUser?.email ?? '',
      documents: documents,
    );
  }

  @override
  Future<SellerApplication> updateStatus({
    required String applicationId,
    required String status,
    String? reasonCode,
    String? note,
  }) async {
    final result = await _client.rpc<dynamic>(
      'admin_review_seller_application',
      params: <String, dynamic>{
        'p_application_id': applicationId,
        'p_status': status,
        'p_reason_code': reasonCode,
        'p_note': note,
      },
    );
    final row = result as Map<String, dynamic>;
    final profile = await _client
        .from('profiles')
        .select('phone, email')
        .eq('id', row['user_id'] as String)
        .maybeSingle();
    final documents = await _fetchDocuments(applicationId);

    return _mapRow(
      row,
      phone: (profile?['phone'] as String?) ?? '',
      email: (profile?['email'] as String?) ?? '',
      documents: documents,
    );
  }

  @override
  Future<List<AppPolicyOption>> fetchPolicyOptions(String policyType) {
    return _contracts.fetchPolicyOptions(policyType);
  }

  SellerApplication _mapRow(
    Map<String, dynamic> row, {
    required String phone,
    required String email,
    required List<SellerDocument> documents,
  }) {
    return SellerApplication(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      sellerType: row['seller_type'] as String? ?? 'individual',
      businessName: row['business_name'] as String? ?? '',
      phone: phone,
      email: email,
      wilayaId: row['wilaya_id'].toString(),
      communeId: row['commune_id'].toString(),
      bio: row['bio'] as String? ?? '',
      verificationStatus: row['verification_status'] as String? ?? 'draft',
      documents: documents,
      reviewReasonCode: row['review_reason_code'] as String?,
      reviewNote: row['review_note'] as String?,
      submittedAt: row['created_at'] == null
          ? null
          : DateTime.tryParse(row['created_at'] as String),
      reviewedAt: row['verified_at'] == null
          ? null
          : DateTime.tryParse(row['verified_at'] as String),
    );
  }

  Future<List<SellerDocument>> _fetchDocuments(String sellerId) async {
    final rows = await _client
        .from('seller_documents')
        .select('id, document_type, storage_path, uploaded_at')
        .eq('seller_id', sellerId)
        .order('uploaded_at');
    final documents = <SellerDocument>[];
    for (final row in rows.whereType<Map<String, dynamic>>()) {
      final storagePath = row['storage_path'] as String? ?? '';
      String? previewUrl;
      if (storagePath.isNotEmpty) {
        previewUrl = await _client.storage
            .from(_verificationDocsBucket)
            .createSignedUrl(storagePath, 60 * 10);
      }
      documents.add(
        SellerDocument(
          id: row['id'] as String,
          documentType: row['document_type'] as String? ?? '',
          storagePath: storagePath,
          uploadedAt:
              DateTime.tryParse(
                row['uploaded_at'] as String? ?? '',
              )?.toLocal() ??
              DateTime.now(),
          publicUrl: previewUrl,
        ),
      );
    }
    return documents;
  }

  Future<void> _syncDocuments({
    required String sellerId,
    required String userId,
    required List<SellerDocumentDraft> documents,
  }) async {
    if (documents.isEmpty) {
      return;
    }
    final existingRows = await _client
        .from('seller_documents')
        .select('id, document_type, storage_path')
        .eq('seller_id', sellerId);
    final existingByType = <String, Map<String, dynamic>>{
      for (final row in existingRows.whereType<Map<String, dynamic>>())
        row['document_type'] as String? ?? '': row,
    };
    for (final document in documents) {
      final existing = existingByType[document.documentType];
      if (existing != null) {
        final existingPath = existing['storage_path'] as String? ?? '';
        if (existingPath.isNotEmpty) {
          await _client.storage.from(_verificationDocsBucket).remove(<String>[
            existingPath,
          ]);
        }
        await _client
            .from('seller_documents')
            .delete()
            .eq('id', existing['id'] as String);
      }
      final storagePath =
          '$userId/$sellerId/${document.documentType}_${DateTime.now().microsecondsSinceEpoch}_${_sanitizeFileName(document.fileName)}';
      await _client.storage
          .from(_verificationDocsBucket)
          .uploadBinary(
            storagePath,
            document.bytes,
            fileOptions: FileOptions(contentType: document.mimeType),
          );
      await _client.from('seller_documents').insert(<String, dynamic>{
        'seller_id': sellerId,
        'document_type': document.documentType,
        'storage_path': storagePath,
      });
    }
  }

  String _sanitizeFileName(String raw) {
    final cleaned = raw.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
    return cleaned.isEmpty ? 'verification_document.jpg' : cleaned;
  }

  static const _verificationDocsBucket = 'verification-docs';
}
