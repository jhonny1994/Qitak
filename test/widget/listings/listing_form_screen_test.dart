import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/features/listings/data/listing_repository.dart';
import 'package:qitak_app/features/listings/domain/listing_draft.dart';
import 'package:qitak_app/features/listings/presentation/listing_form_screen.dart';
import 'package:qitak_app/features/listings/providers/listing_media_picker_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

import '../../fixtures/discovery_filter_taxonomy_fixture.dart';
import '../../fixtures/listing_media_fixture.dart';
import '../../support/slice_test_bootstrap.dart';

class _RecordingListingRepository implements ListingRepository {
  @override
  bool get isLocal => true;

  ListingDraft? submittedDraft;
  ListingWorkflowAction? submittedAction;

  @override
  Future<bool> hasUserReportedListing(String listingId) async => false;

  @override
  Future<void> reportListing(String listingId, String reason) async {}

  @override
  Future<ListingSubmissionResult> submitListing({
    required ListingDraft draft,
    required ListingWorkflowAction action,
  }) async {
    submittedDraft = draft;
    submittedAction = action;
    return ListingSubmissionResult(
      listingId: 'listing-test-1',
      status: action == ListingWorkflowAction.saveDraft
          ? 'draft'
          : 'pending_review',
    );
  }
}

class _FakeListingMediaPicker implements ListingMediaPicker {
  _FakeListingMediaPicker(this.result);

  final List<ListingMediaSelection> result;

  @override
  Future<List<ListingMediaSelection>> pickImages({
    int maxImages = 6,
  }) async => result;
}

void main() {
  const approvedApplication = SellerApplication(
    id: 'seller-app-seller-001',
    userId: 'seller-001',
    sellerType: 'business',
    businessName: 'Samir Auto Parts',
    phone: '+213555000222',
    email: 'seller@qitak.test',
    wilayaId: '1',
    communeId: '1001',
    bio: 'Verified seller profile',
    verificationStatus: 'approved',
  );

  Finder fieldKey(String prefix) => find.byWidgetPredicate(
    (widget) =>
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith(prefix),
  );

  testWidgets('requires structured selectors before submit', (tester) async {
    final repository = _RecordingListingRepository();
    final scope = await buildSliceTestScope(
      const SliceTestMaterialShell(
        child: Scaffold(body: ListingFormScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        listingRepositoryProvider.overrideWithValue(repository),
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
        currentSellerApplicationProvider.overrideWith(
          (ref) async => approvedApplication,
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final communeField = tester.widget<QitakDropdownField<String>>(
      fieldKey('listing-commune-field'),
    );
    final modelField = tester.widget<QitakDropdownField<String>>(
      fieldKey('listing-model-field'),
    );
    final yearField = tester.widget<QitakDropdownField<int>>(
      fieldKey('listing-year-field'),
    );
    expect(communeField.onChanged, isNull);
    expect(modelField.onChanged, isNull);
    expect(yearField.onChanged, isNull);

    await tester.ensureVisible(find.byKey(const Key('listing-submit-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('listing-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Select a category.'), findsOneWidget);
    expect(find.text('Select a wilaya.'), findsOneWidget);
    expect(find.text('Select a car make.'), findsOneWidget);
    expect(find.text('Select a car model.'), findsOneWidget);
    expect(find.text('Select a year.'), findsOneWidget);
    expect(
      find.text('Add at least two listing photos before review submission.'),
      findsOneWidget,
    );
  });

  testWidgets('submits a structured listing draft with media', (tester) async {
    final repository = _RecordingListingRepository();
    final scope = await buildSliceTestScope(
      const SliceTestMaterialShell(
        child: Scaffold(body: ListingFormScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        listingRepositoryProvider.overrideWithValue(repository),
        listingMediaPickerProvider.overrideWithValue(
          _FakeListingMediaPicker([
            ListingMediaSelection(
              fileName: 'headlight.png',
              mimeType: 'image/png',
              bytes: buildTestListingMediaBytes(),
            ),
            ListingMediaSelection(
              fileName: 'headlight-2.png',
              mimeType: 'image/png',
              bytes: buildTestListingMediaBytes(),
            ),
          ]),
        ),
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
        currentSellerApplicationProvider.overrideWith(
          (ref) async => approvedApplication,
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('listing-title-field')),
      'Headlight assembly',
    );

    await tester.tap(fieldKey('listing-category-field'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lighting').last);
    await tester.pumpAndSettle();

    await tester.tap(fieldKey('listing-wilaya-field'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adrar').last);
    await tester.pumpAndSettle();

    await tester.tap(fieldKey('listing-commune-field'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adrar').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(fieldKey('listing-make-field'));
    await tester.pumpAndSettle();
    await tester.tap(fieldKey('listing-make-field'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Audi').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(fieldKey('listing-model-field'));
    await tester.tap(fieldKey('listing-model-field'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TT Coupe').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(fieldKey('listing-year-field'));
    await tester.pumpAndSettle();
    await tester.tap(fieldKey('listing-year-field'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2018').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('listing-price-field')),
      '18500',
    );
    await tester.enterText(
      find.byKey(const Key('listing-quantity-field')),
      '2',
    );
    await tester.ensureVisible(find.text('Like new'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Like new'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('listing-description-field')),
      'Clear lens and working mounts.',
    );
    await tester.ensureVisible(
      find.byKey(const Key('listing-media-add-button')),
    );
    await tester.tap(find.byKey(const Key('listing-media-add-button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('listing-exchange-switch')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('listing-exchange-switch')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('listing-submit-button')));
    await tester.tap(find.byKey(const Key('listing-submit-button')));
    await tester.pumpAndSettle();

    expect(repository.submittedDraft, isNotNull);
    expect(repository.submittedDraft?.title, 'Headlight assembly');
    expect(repository.submittedDraft?.categoryId, 'lighting');
    expect(repository.submittedDraft?.wilayaCode, '1');
    expect(repository.submittedDraft?.communeCode, '1001');
    expect(repository.submittedDraft?.brandCode, 'Audi');
    expect(repository.submittedDraft?.modelCode, 'TT Coupe');
    expect(repository.submittedDraft?.year, 2018);
    expect(repository.submittedDraft?.price, 18500);
    expect(repository.submittedDraft?.quantity, 2);
    expect(repository.submittedDraft?.condition, 'like_new');
    expect(
      repository.submittedDraft?.description,
      'Clear lens and working mounts.',
    );
    expect(repository.submittedDraft?.exchangeEnabled, isTrue);
    expect(repository.submittedDraft?.media, hasLength(2));
    expect(repository.submittedDraft?.media.first.fileName, 'headlight.png');
    expect(
      repository.submittedAction,
      ListingWorkflowAction.submit,
    );
  });

  testWidgets('picked media can be removed before submit', (tester) async {
    final repository = _RecordingListingRepository();
    final scope = await buildSliceTestScope(
      const SliceTestMaterialShell(
        child: Scaffold(body: ListingFormScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        listingRepositoryProvider.overrideWithValue(repository),
        listingMediaPickerProvider.overrideWithValue(
          _FakeListingMediaPicker([
            ListingMediaSelection(
              fileName: 'headlight.png',
              mimeType: 'image/png',
              bytes: buildTestListingMediaBytes(),
            ),
          ]),
        ),
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
        currentSellerApplicationProvider.overrideWith(
          (ref) async => approvedApplication,
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('listing-media-add-button')),
    );
    await tester.tap(find.byKey(const Key('listing-media-add-button')));
    await tester.pumpAndSettle();

    expect(find.text('headlight.png'), findsOneWidget);

    await tester.tap(find.byKey(const Key('listing-media-remove-0')));
    await tester.pumpAndSettle();

    expect(find.text('headlight.png'), findsNothing);
  });
}
