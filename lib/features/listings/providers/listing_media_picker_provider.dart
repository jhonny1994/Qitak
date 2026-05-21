import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';

export 'package:qitak_app/features/listings/domain/listing_media_selection.dart';

// ignore: one_member_abstracts, reason: Widget tests override this platform boundary.
abstract class ListingMediaPicker {
  Future<List<ListingMediaSelection>> pickImages({
    int maxImages = 6,
  });
}

final listingMediaPickerProvider = Provider<ListingMediaPicker>((ref) {
  return DeviceListingMediaPicker(ImagePicker());
});

class DeviceListingMediaPicker implements ListingMediaPicker {
  const DeviceListingMediaPicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<List<ListingMediaSelection>> pickImages({
    int maxImages = 6,
  }) async {
    final files = await _picker.pickMultiImage(
      imageQuality: 88,
      maxWidth: 2400,
      maxHeight: 2400,
    );

    return Future.wait(
      files.take(maxImages).map((file) async {
        final bytes = await file.readAsBytes();
        return ListingMediaSelection(
          fileName: file.name,
          mimeType: lookupMimeType(file.name) ?? 'image/jpeg',
          bytes: bytes,
        );
      }),
    );
  }
}
