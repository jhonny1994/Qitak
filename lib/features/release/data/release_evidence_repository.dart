class ReleaseEvidenceRepository {
  String buildRef(String gateName, DateTime checkedAt) {
    final safe = gateName.replaceAll(' ', '_').toLowerCase();
    return 'reports/release/${checkedAt.toIso8601String()}__$safe.txt';
  }
}
