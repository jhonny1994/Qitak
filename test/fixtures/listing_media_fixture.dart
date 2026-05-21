import 'dart:convert';
import 'dart:typed_data';

const _tinyTransparentPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9p0N4a4AAAAASUVORK5CYII=';

const testListingMediaDataUri =
    'data:image/png;base64,$_tinyTransparentPngBase64';

Uint8List buildTestListingMediaBytes() =>
    base64Decode(_tinyTransparentPngBase64);
