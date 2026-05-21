import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';

// ignore: one_member_abstracts, reason: Widget tests override this platform boundary.
abstract class SellerDocumentPicker {
  Future<SellerDocumentDraft?> pickDocument({
    required String documentType,
  });
}

final sellerDocumentPickerProvider = Provider<SellerDocumentPicker>((ref) {
  return DeviceSellerDocumentPicker(ImagePicker());
});

class DeviceSellerDocumentPicker implements SellerDocumentPicker {
  const DeviceSellerDocumentPicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<SellerDocumentDraft?> pickDocument({
    required String documentType,
  }) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 2400,
      maxHeight: 2400,
    );
    if (file == null) {
      return null;
    }
    final bytes = await file.readAsBytes();
    return SellerDocumentDraft(
      documentType: documentType,
      fileName: file.name,
      mimeType: lookupMimeType(file.name) ?? 'image/jpeg',
      bytes: bytes,
    );
  }
}
