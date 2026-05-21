import 'dart:convert';
import 'dart:typed_data';

class ListingMediaSelection {
  const ListingMediaSelection({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;

  String toDataUri() => 'data:$mimeType;base64,${base64Encode(bytes)}';
}
