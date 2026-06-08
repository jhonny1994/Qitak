import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/admin/data/admin_team_repository.dart';
import 'package:qitak_app/features/admin/presentation/admin_team_screen.dart';
import 'package:qitak_app/generated/l10n.dart';

void main() {
  testWidgets('admin team separates invite, identity, and dangerous actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestShell(
        overrides: [
          adminTeamRepositoryProvider.overrideWithValue(
            _FailingAdminTeamRepository(),
          ),
        ],
        child: const Scaffold(body: AdminTeamScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('admin-team-invite')), findsOneWidget);
    expect(find.byKey(const Key('admin-team-members')), findsOneWidget);
    expect(find.byKey(const Key('admin-team-danger-actions')), findsWidgets);
  });

  testWidgets('shows an error when inviting an admin fails', (tester) async {
    final repository = _FailingAdminTeamRepository();
    await tester.pumpWidget(
      _TestShell(
        overrides: [
          adminTeamRepositoryProvider.overrideWithValue(repository),
        ],
        child: const Scaffold(body: AdminTeamScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ops@qitak.test');
    await tester.tap(find.byKey(const Key('admin-team-invite-button')));
    await tester.pumpAndSettle();

    expect(find.text('Bad state: Invite failed'), findsOneWidget);
    expect(find.text('ops@qitak.test'), findsOneWidget);
  });

  testWidgets('shows an error when updating a team member fails', (
    tester,
  ) async {
    final repository = _FailingAdminTeamRepository();
    await tester.pumpWidget(
      _TestShell(
        overrides: [
          adminTeamRepositoryProvider.overrideWithValue(repository),
        ],
        child: const Scaffold(body: AdminTeamScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Suspend'));
    await tester.pumpAndSettle();

    expect(find.text('Bad state: Update failed'), findsOneWidget);
  });
}

class _TestShell extends StatelessWidget {
  const _TestShell({
    required this.child,
    this.overrides = const <Object>[],
  });

  final Widget child;
  final List<Object> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        locale: const Locale('en'),
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: child,
      ),
    );
  }
}

class _FailingAdminTeamRepository implements AdminTeamRepository {
  @override
  Future<void> invite({
    required String email,
    required String role,
  }) async {
    throw StateError('Invite failed');
  }

  @override
  Future<List<AdminTeamMember>> listMembers() async => const <AdminTeamMember>[
    AdminTeamMember(
      id: 'admin-1',
      fullName: 'Amina Ops',
      email: 'admin@qitak.test',
      role: 'admin',
      isActive: true,
    ),
  ];

  @override
  Future<void> updateMember({
    required String userId,
    required String action,
  }) async {
    throw StateError('Update failed');
  }
}
