import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';

void main() {
  test(
    'local messaging realtime subscription path stays absent and non-throwing',
    () async {
      final repository = LocalMessagingRepository();
      var subscribed = false;
      var receivedMessage = false;
      Object? reportedError;

      Object? channel;
      expect(() {
        channel = repository.subscribeToThreadMessages(
          threadId: 'thread-1',
          onMessage: (_) => receivedMessage = true,
          onSubscribed: () => subscribed = true,
          onError: (error) => reportedError = error,
        );
      }, returnsNormally);

      await Future<void>.delayed(Duration.zero);

      expect(channel, isNull);
      expect(subscribed, isFalse);
      expect(receivedMessage, isFalse);
      expect(reportedError, isNull);
    },
  );
}
