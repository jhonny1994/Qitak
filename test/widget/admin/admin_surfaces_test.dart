import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/admin/presentation/admin_team_screen.dart';
import 'package:qitak_app/features/admin/presentation/seller_verification_queue_screen.dart';
import 'package:qitak_app/features/admin/presentation/verification_detail_screen.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/generated/l10n.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('seller verification queue renders empty state', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerVerificationQueueScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'admin@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Seller verification queue'), findsOneWidget);
    expect(find.text('Queue is empty'), findsOneWidget);
  });

  testWidgets('admin team renders invite action surface', (tester) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: AdminTeamScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'superadmin@qitak.test',
      },
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Admin team'), findsOneWidget);
    expect(find.byKey(const Key('admin-team-invite-button')), findsOneWidget);
  });

  testWidgets('verification detail renders backend policy options', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/admin/verifications/:id',
          builder: (context, state) => VerificationDetailScreen(
            verificationId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/admin/verifications',
          builder: (context, state) => const Scaffold(body: Text('queue')),
        ),
      ],
      initialLocation: '/admin/verifications/app-1',
    );

    final scope = await buildTestScope(
      MaterialApp.router(
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
        routerConfig: router,
      ),
      sellerApplicationRepositoryOverride: _PolicyAwareSellerRepository(),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Business registration'), findsOneWidget);
    expect(find.text('Reason code'), findsOneWidget);
  });
}

class _PolicyAwareSellerRepository implements SellerApplicationRepository {
  @override
  Future<SellerApplication?> fetchById(String applicationId) async {
    return SellerApplication(
      id: applicationId,
      userId: 'user-1',
      sellerType: 'business',
      businessName: 'Qitak Motors',
      phone: '+213555000111',
      email: 'seller@qitak.test',
      wilayaId: '16',
      communeId: '1601',
      bio: 'Parts specialist',
      verificationStatus: 'submitted',
      documents: <SellerDocument>[
        SellerDocument(
          id: 'doc-1',
          documentType: 'business_registration',
          storagePath: 'seller/docs/business-registration.png',
          uploadedAt: DateTime(2026, 5, 25),
        ),
      ],
    );
  }

  @override
  Future<List<AppPolicyOption>> fetchPolicyOptions(String policyType) async {
    if (policyType == 'seller_document_type') {
      return const <AppPolicyOption>[
        AppPolicyOption(
          policyType: 'seller_document_type',
          code: 'business_registration',
          labelKey: 'sellerDocumentBusinessRegistrationLabel',
          active: true,
          sortOrder: 10,
        ),
      ];
    }
    if (policyType == 'seller_verification_reason_code') {
      return const <AppPolicyOption>[
        AppPolicyOption(
          policyType: 'seller_verification_reason_code',
          code: 'identity_mismatch',
          labelKey: 'adminVerificationReasonIdentityMismatch',
          active: true,
          sortOrder: 10,
        ),
      ];
    }
    return const <AppPolicyOption>[];
  }

  @override
  Future<SellerApplication?> fetchCurrentForUser(String userId) async => null;

  @override
  Future<List<SellerApplication>> listPendingApplications() async =>
      const <SellerApplication>[];

  @override
  Future<SellerApplication> submitApplication({
    required String userId,
    required SellerApplicationDraft draft,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SellerApplication> updateStatus({
    required String applicationId,
    required String status,
    String? reasonCode,
    String? note,
  }) {
    throw UnimplementedError();
  }
}
