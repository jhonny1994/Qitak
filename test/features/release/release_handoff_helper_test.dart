import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/release_handoff_helper.dart';

void main() {
  test('signoff helper returns owner and iso timestamp', () {
    final result = ReleaseHandoffHelper.signoff(
      owner: 'ops',
      at: DateTime.utc(2026, 5, 13, 10),
    );
    expect(result['owner'], 'ops');
    expect(result['at'], '2026-05-13T10:00:00.000Z');
  });
}
