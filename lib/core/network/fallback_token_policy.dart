String nonEmptySemanticToken(
  String? value, {
  required String fallbackToken,
}) {
  final normalized = value?.trim() ?? '';
  if (normalized.isNotEmpty) {
    return normalized;
  }
  return fallbackToken;
}
