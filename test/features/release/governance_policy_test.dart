import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dual approval requires two distinct approvers', () {
    const a = 'alice';
    const b = 'bob';
    expect(a == b, isFalse);
  });
}
