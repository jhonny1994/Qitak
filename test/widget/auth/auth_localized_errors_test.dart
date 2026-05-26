import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/l10n/app_error_localization.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:qitak_app/generated/l10n.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('auth repository error strings are localized in english', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: _AuthErrorTextProbe()),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Session not found.'), findsOneWidget);
    expect(
      find.text('Unable to sign in. Please try again.'),
      findsOneWidget,
    );
    expect(
      find.text('Network unavailable. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(find.text('Invalid email or password.'), findsOneWidget);
    expect(
      find.text('An account with this email already exists.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Account created. Please check your email and click the confirmation '
        'link before signing in.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('typed app exception is localized in presentation', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: _AuthExceptionProbe()),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password.'), findsOneWidget);
  });
}

class _AuthErrorTextProbe extends StatelessWidget {
  const _AuthErrorTextProbe();

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Column(
      children: [
        Text(l10n.authErrorSessionNotFound),
        Text(l10n.authErrorUnableSignIn),
        Text(l10n.errorNetworkUnavailable),
        Text(l10n.authErrorInvalidEmailOrPassword),
        Text(l10n.authErrorEmailAlreadyExists),
        Text(l10n.authErrorCheckEmailConfirmation),
      ],
    );
  }
}

class _AuthExceptionProbe extends StatelessWidget {
  const _AuthExceptionProbe();

  @override
  Widget build(BuildContext context) {
    final error = AppException.fromCode(AppErrorCode.invalidCredentials);
    return Text(context.appExceptionMessage(error));
  }
}
