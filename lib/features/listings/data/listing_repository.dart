import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/listings/data/local_listing_store.dart';
import 'package:qitak_app/features/listings/domain/listing_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ListingRepository {
  const ListingRepository();

  bool get isLocal;

  Future<void> reportListing(String listingId, String reason);

  Future<bool> hasUserReportedListing(String listingId);

  Future<ListingSubmissionResult> submitListing({
    required ListingDraft draft,
    required ListingWorkflowAction action,
  });
}

enum ListingWorkflowAction { saveDraft, submit }

class ListingSubmissionResult {
  const ListingSubmissionResult({
    required this.listingId,
    required this.status,
  });

  final String listingId;
  final String status;
}

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is required for listing writes.');
  }
  return SupabaseListingRepository(client);
});

class LocalListingRepository implements ListingRepository {
  LocalListingRepository(this._prefs, this._profile);

  final SharedPreferences _prefs;
  final AccountProfile? _profile;

  @override
  bool get isLocal => true;

  @override
  Future<bool> hasUserReportedListing(String listingId) async => false;

  @override
  Future<void> reportListing(String listingId, String reason) async {}

  @override
  Future<ListingSubmissionResult> submitListing({
    required ListingDraft draft,
    required ListingWorkflowAction action,
  }) async {
    final profile = _profile;
    if (profile == null) {
      throw const AppException('Session not found.');
    }

    final now = DateTime.now().toUtc();
    final id = 'local-${now.millisecondsSinceEpoch}-${Random().nextInt(9999)}';
    final store = LocalListingStore(_prefs);
    await store.append(
      LocalStoredListing.fromDraft(
        id: id,
        sellerUserId: profile.id,
        sellerName: profile.fullName,
        draft: draft,
        createdAt: now,
        status: action == ListingWorkflowAction.saveDraft
            ? 'draft'
            : 'pending_review',
      ),
    );
    return ListingSubmissionResult(
      listingId: id,
      status: action == ListingWorkflowAction.saveDraft
          ? 'draft'
          : 'pending_review',
    );
  }
}

class SupabaseListingRepository implements ListingRepository {
  SupabaseListingRepository(this._client);

  final SupabaseClient _client;

  @override
  bool get isLocal => false;

  @override
  Future<bool> hasUserReportedListing(String listingId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AppException('Session not found.');
    }

    final existing = await _client
        .from('reports')
        .select('id')
        .eq('reporter_id', user.id)
        .eq('reported_entity_type', 'listing')
        .eq('reported_entity_id', listingId)
        .maybeSingle();
    return existing != null;
  }

  @override
  Future<void> reportListing(String listingId, String reason) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AppException('Session not found.');
    }

    try {
      await _client.from('reports').insert(<String, dynamic>{
        'reporter_id': user.id,
        'reported_entity_type': 'listing',
        'reported_entity_id': listingId,
        'report_type': reason,
      });
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
  }

  @override
  Future<ListingSubmissionResult> submitListing({
    required ListingDraft draft,
    required ListingWorkflowAction action,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AppException('Session not found.');
    }

    final mediaRows = <Map<String, dynamic>>[
      for (final media in draft.persistedMedia)
        <String, dynamic>{
          'storage_path': media.storagePath,
          'public_url': media.publicUrl,
          'mime_type': media.mimeType,
          'sort_order': media.sortOrder,
        },
    ];
    final draftId =
        draft.listingId ??
        'local-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
    for (var index = 0; index < draft.media.length; index++) {
      final media = draft.media[index];
      final storagePath =
          '${user.id}/$draftId/${index}_${_sanitizeFileName(media.fileName)}';
      await _client.storage
          .from(_listingMediaBucket)
          .uploadBinary(
            storagePath,
            media.bytes,
            fileOptions: FileOptions(
              contentType: media.mimeType,
            ),
          );
      mediaRows.add(<String, dynamic>{
        'storage_path': storagePath,
        'public_url': _client.storage
            .from(_listingMediaBucket)
            .getPublicUrl(storagePath),
        'mime_type': media.mimeType,
        'sort_order': index,
      });
    }

    final payload = <String, dynamic>{
      if ((draft.listingId ?? '').isNotEmpty) 'listing_id': draft.listingId,
      'title': draft.title,
      'description': draft.description,
      'price': draft.price,
      'wilaya_code': draft.wilayaCode,
      'commune_code': draft.communeCode,
      'wilaya_id': draft.wilayaCode,
      'commune_id': draft.communeCode,
      'category_id': draft.categoryId,
      'condition': draft.condition,
      'quantity': draft.quantity,
      'exchange_enabled': draft.exchangeEnabled,
      'exchange_description': draft.exchangeDescription,
      'brand': draft.brandCode,
      'fulfillment_mode': 'pickup',
      'vehicle_fitment': <Map<String, dynamic>>[
        <String, dynamic>{
          'make': draft.brandCode,
          'model': draft.modelCode,
          'year': draft.year,
        },
      ],
      'brand_code': draft.brandCode,
      'model_code': draft.modelCode,
      'model_year': draft.year,
      'media': mediaRows,
    };

    try {
      final functionName = action == ListingWorkflowAction.saveDraft
          ? 'seller_upsert_listing_draft'
          : 'seller_submit_listing';
      final result = await _client.rpc<dynamic>(
        functionName,
        params: <String, dynamic>{'payload': payload},
      );
      final row = result as Map<String, dynamic>;
      return ListingSubmissionResult(
        listingId: row['listing_id'] as String,
        status: row['status'] as String? ?? '',
      );
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
  }

  static const _listingMediaBucket = 'listing-media';

  String _sanitizeFileName(String raw) {
    final cleaned = raw.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
    return cleaned.isEmpty ? 'listing_media.jpg' : cleaned;
  }
}
