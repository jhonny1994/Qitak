class ReleaseHandoffHelper {
  static Map<String, String> signoff({
    required String owner,
    required DateTime at,
  }) {
    return {'owner': owner, 'at': at.toUtc().toIso8601String()};
  }
}
