import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/listings/data/listing_repository.dart';
import 'package:qitak_app/features/listings/providers/listing_media_picker_provider.dart';

void main() {
  test('bounded upload coordinator preserves original sort order', () async {
    final events = <String>[];
    const coordinator = ListingMediaUploadCoordinator(
      maxConcurrentUploads: 2,
    );

    final media = <ListingMediaSelection>[
      _media('0.png'),
      _media('1.png'),
      _media('2.png'),
    ];

    final rows = await coordinator.upload(
      media: media,
      buildStoragePath: (index, media) => 'listing/$index-${media.fileName}',
      uploadBinary: (storagePath, media) async {
        events.add('upload:$storagePath');
      },
      buildPublicUrl: (storagePath) => 'https://cdn.test/$storagePath',
    );

    expect(
      rows.map((row) => row['sort_order']),
      orderedEquals(<int>[0, 1, 2]),
    );
    expect(
      rows.map((row) => row['storage_path']),
      orderedEquals(<String>[
        'listing/0-0.png',
        'listing/1-1.png',
        'listing/2-2.png',
      ]),
    );
    expect(events, hasLength(3));
  });

  test('bounded upload coordinator surfaces upload failure', () async {
    const coordinator = ListingMediaUploadCoordinator(
      maxConcurrentUploads: 2,
    );

    await expectLater(
      () => coordinator.upload(
        media: <ListingMediaSelection>[
          _media('0.png'),
          _media('1.png'),
        ],
        buildStoragePath: (index, media) => 'listing/$index-${media.fileName}',
        uploadBinary: (storagePath, media) async {
          if (storagePath.contains('1-1.png')) {
            throw StateError('upload failed');
          }
        },
        buildPublicUrl: (storagePath) => 'https://cdn.test/$storagePath',
      ),
      throwsA(isA<StateError>()),
    );
  });
}

ListingMediaSelection _media(String fileName) {
  return ListingMediaSelection(
    fileName: fileName,
    mimeType: 'image/png',
    bytes: Uint8List.fromList(<int>[1, 2, 3]),
  );
}
