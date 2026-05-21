import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';

void main() {
  test('route intent stores route target', () {
    final intent = PostAuthRedirectIntent.route('/profile');
    expect(intent.targetType, IntentTargetType.route);
    expect(intent.targetValue, '/profile');
  });

  test('action intent stores action target', () {
    final intent = PostAuthRedirectIntent.action('buy-intent');
    expect(intent.targetType, IntentTargetType.action);
    expect(intent.targetValue, 'buy-intent');
  });

  test('query serialization preserves encoded arguments', () {
    final intent = PostAuthRedirectIntent.action(
      'save-listing',
      arguments: const <String, String>{
        'route': '/listing/listing-1',
        'listingId': 'listing-1',
      },
    );
    final restored = PostAuthRedirectIntent.fromQueryParameters(
      redirectPath: intent.targetValue,
      redirectType: intent.targetType,
      encodedArguments: intent.toQueryParameters()['intentArgs'],
    );

    expect(restored, isNotNull);
    expect(restored!.targetType, IntentTargetType.action);
    expect(restored.arguments?['route'], '/listing/listing-1');
    expect(restored.arguments?['listingId'], 'listing-1');
  });
}
