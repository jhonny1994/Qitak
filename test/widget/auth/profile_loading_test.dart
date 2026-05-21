import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/presentation/profile_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('profile screen shows skeletons while auth session loads', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: ProfileScreen()),
      ),
      overrides: [
        authSessionProvider.overrideWith(_LoadingAuthSessionNotifier.new),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pump();

    expect(find.byType(QitakSkeletonBox), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.width == 0 && widget.height == 0,
      ),
      findsNothing,
    );
  });
}

class _LoadingAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => AuthSessionState.loading();
}
