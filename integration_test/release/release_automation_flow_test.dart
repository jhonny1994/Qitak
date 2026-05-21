import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/release/domain/release_handoff_helper.dart';

void main() {
  test('handoff helper can build signoff payload', () {
    final payload = ReleaseHandoffHelper.signoff(
      owner: 'qa',
      at: DateTime.utc(2026, 5, 13, 9),
    );
    expect(payload['owner'], 'qa');
    expect(payload['at'], isNotNull);
  });
}
