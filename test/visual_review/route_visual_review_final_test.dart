@Tags(<String>['visual-review'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/admin/data/admin_reports_repository.dart';
import 'package:qitak_app/features/admin/data/conversation_oversight_repository.dart';
import 'package:qitak_app/features/admin/domain/admin_report.dart';
import 'package:qitak_app/features/admin/domain/conversation_oversight_case.dart';
import 'package:qitak_app/features/admin/presentation/conversation_oversight_screen.dart';
import 'package:qitak_app/features/admin/presentation/dispute_detail_screen.dart';
import 'package:qitak_app/features/admin/presentation/report_detail_screen.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/presentation/appearance_preferences_screen.dart';
import 'package:qitak_app/features/auth/presentation/language_selection_screen.dart';
import 'package:qitak_app/features/auth/presentation/legal_information_screen.dart';
import 'package:qitak_app/features/auth/presentation/profile_screen.dart';
import 'package:qitak_app/features/auth/presentation/reset_password_screen.dart';
import 'package:qitak_app/features/auth/presentation/sign_up_screen.dart';
import 'package:qitak_app/features/auth/presentation/splash_screen.dart';
import 'package:qitak_app/features/auth/presentation/unknown_route_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/messaging/domain/conversation_message.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_screen.dart';
import 'package:qitak_app/features/messaging/providers/messaging_provider.dart';
import 'package:qitak_app/features/support/data/support_repository.dart';
import 'package:qitak_app/features/support/presentation/support_center_screen.dart';
import 'package:qitak_app/features/support/presentation/support_ticket_create_sheet.dart';
import 'package:qitak_app/features/transactions/data/dispute_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_dispute.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_request_screen.dart';
import 'package:qitak_app/generated/l10n.dart';

import '../fixtures/seeded_discovery_repository.dart';
import '../test_bootstrap.dart';

Future<void> _prepareViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _restoreSessionFor<T extends Widget>(WidgetTester tester) async {
  final container = ProviderScope.containerOf(tester.element(find.byType(T)));
  await container.read(authSessionProvider.notifier).restore();
  await tester.pumpAndSettle();
}

Future<void> _captureScaffold(
  WidgetTester tester,
  String goldenName,
) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
  await expectLater(
    find.byType(Scaffold).first,
    matchesGoldenFile('goldens/$goldenName'),
  );
}

Future<void> _captureScaffoldInBothThemes(
  WidgetTester tester, {
  required String goldenBaseName,
  required Future<void> Function(ThemeMode mode) pumpForMode,
}) async {
  for (final mode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpForMode(mode);
    final suffix = mode == ThemeMode.light ? 'light' : 'dark';
    await _captureScaffold(tester, '$goldenBaseName-$suffix.png');
  }
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 10 && finder.evaluate().isEmpty; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _FakeConversationOversightRepository
    implements ConversationOversightRepository {
  @override
  Future<void> attachNote({
    required String threadId,
    required String purpose,
    required String note,
  }) async {}

  @override
  Future<ConversationOversightCase> loadCase({
    required String threadId,
    required String purpose,
    String? note,
  }) async {
    return ConversationOversightCase(
      threadId: threadId,
      listingId: 'listing-1',
      listingTitle: 'Headlight assembly',
      buyerUserId: 'buyer-001',
      sellerUserId: 'seller-001',
      buyerName: 'Karim Benali',
      sellerName: 'Samir Auto Parts',
      messages: [
        ConversationMessage(
          id: 'm1',
          threadId: 'thread-1',
          body: 'Is it still available?',
          senderId: 'buyer-001',
          createdAt: DateTime(2026, 1, 2, 10),
        ),
        ConversationMessage(
          id: 'm2',
          threadId: 'thread-1',
          body: 'Yes, ready for pickup.',
          senderId: 'seller-001',
          createdAt: DateTime(2026, 1, 2, 10, 5),
        ),
      ],
      transactionId: 'tx-1',
      reportId: 'report-1',
      disputeId: 'dispute-1',
    );
  }
}

void main() {
  testWidgets('captures profile screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'profile-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: ProfileScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<ProfileScreen>(tester);
      },
    );
  });

  testWidgets('captures support center screen', (tester) async {
    await _prepareViewport(tester);

    const buyerProfile = AccountProfile(
      id: 'buyer-1',
      email: 'buyer@qitak.test',
      fullName: 'Karim Benali',
      phone: '+213555444333',
      role: AccountRole.buyer,
      language: 'en',
      isActive: true,
    );

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'support-center-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: SupportCenterScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
          overrides: <Object>[
            supportRepositoryProvider.overrideWithValue(
              LocalSupportRepository(buyerProfile),
            ),
            supportReasonOptionsProvider.overrideWith((ref) async {
              return const <AppPolicyOption>[
                AppPolicyOption(
                  policyType: 'support_reason_code',
                  code: 'payment_issue',
                  labelKey: 'supportReasonPaymentIssue',
                  active: true,
                  sortOrder: 10,
                ),
              ];
            }),
          ],
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<SupportCenterScreen>(tester);
      },
    );
  });

  testWidgets('captures legal information screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'legal-information-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: LegalInformationScreen()),
          ),
        );

        await tester.pumpWidget(scope);
      },
    );
  });

  testWidgets('captures language selection screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'language-selection-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: LanguageSelectionScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<LanguageSelectionScreen>(tester);
      },
    );
  });

  testWidgets('captures appearance preferences screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'appearance-preferences-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: AppearancePreferencesScreen()),
          ),
        );

        await tester.pumpWidget(scope);
      },
    );
  });

  testWidgets('captures reset password screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'reset-password-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: ResetPasswordScreen()),
          ),
        );

        await tester.pumpWidget(scope);
      },
    );
  });

  testWidgets('captures sign up screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'sign-up-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: SignUpScreen()),
          ),
        );

        await tester.pumpWidget(scope);
      },
    );
  });

  testWidgets('captures splash screen loading state', (tester) async {
    await _prepareViewport(tester);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: SplashScreen()),
        ),
        GoRoute(
          path: '/intro/1',
          builder: (context, state) => const Scaffold(body: Text('intro-1')),
        ),
      ],
    );

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'splash-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          MaterialApp.router(
            locale: const Locale('en'),
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: mode,
            routerConfig: router,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
          ),
        );

        await tester.pumpWidget(scope);
      },
    );
  });

  testWidgets('captures unknown route screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'unknown-route-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: UnknownRouteScreen(requestedPath: '/bad/path'),
            ),
          ),
        );

        await tester.pumpWidget(scope);
      },
    );
  });

  testWidgets('captures conversation screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'conversation-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: ConversationScreen(threadId: 'thread-1'),
            ),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<ConversationScreen>(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ConversationScreen)),
        );
        await container
            .read(messagingProvider.notifier)
            .sendMessage(
              threadId: 'thread-1',
              senderId: 'buyer-001',
              body: 'Thread one message',
            );
        await container
            .read(messagingProvider.notifier)
            .sendMessage(
              threadId: 'thread-1',
              senderId: 'seller-001',
              body: 'Seller reply',
            );
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('captures transaction request screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'transaction-request-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: TransactionRequestScreen(listingId: 'listing-1'),
            ),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
          overrides: [
            discoveryRepositoryProvider.overrideWithValue(
              seededDiscoveryRepository,
            ),
          ],
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<TransactionRequestScreen>(tester);
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('captures report detail screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'report-detail-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: ReportDetailScreen(reportId: 'report-1'),
            ),
          ),
          overrides: [
            adminReportProvider('report-1').overrideWith(
              (ref) async => AdminReport(
                id: 'report-1',
                reporterUserId: 'buyer-001',
                reporterName: 'Karim Benali',
                entityType: 'listing',
                entityId: 'listing-1',
                entityPreview: 'Headlight assembly',
                reason: 'spam',
                description: 'Listing details look misleading.',
                status: 'open',
                createdAt: DateTime(2026, 6, 2),
                reporterHistoryCount: 2,
                entityHistoryCount: 1,
              ),
            ),
            reportDecisionPolicyOptionsProvider.overrideWith(
              (ref) async => const [
                AppPolicyOption(
                  policyType: 'report_resolution_decision',
                  code: 'dismiss',
                  labelKey: 'adminReportDecisionDismiss',
                  active: true,
                  sortOrder: 10,
                ),
                AppPolicyOption(
                  policyType: 'report_resolution_decision',
                  code: 'warn_seller',
                  labelKey: 'adminReportDecisionWarnSeller',
                  active: true,
                  sortOrder: 20,
                ),
              ],
            ),
            reportReasonPolicyOptionsProvider.overrideWith(
              (ref) async => const [
                AppPolicyOption(
                  policyType: 'report_resolution_reason_code',
                  code: 'spam',
                  labelKey: 'adminReportReasonSpam',
                  active: true,
                  sortOrder: 10,
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(scope);
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('captures dispute detail screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'dispute-detail-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: DisputeDetailScreen(disputeId: 'dispute-1'),
            ),
          ),
          overrides: [
            adminDisputeProvider('dispute-1').overrideWith(
              (ref) async => TransactionDispute(
                id: 'dispute-1',
                transactionId: 'tx-1',
                createdByUserId: 'buyer-001',
                reason: 'wrong_part',
                description: 'The part does not match the promised fitment.',
                status: 'open',
                createdAt: DateTime(2026, 6, 2),
                buyerName: 'Karim Benali',
                sellerName: 'Samir Auto Parts',
                listingTitle: 'Headlight assembly',
                conversationId: 'thread-1',
              ),
            ),
            disputeDecisionPolicyOptionsProvider.overrideWith(
              (ref) async => const [
                AppPolicyOption(
                  policyType: 'dispute_resolution_decision',
                  code: 'buyer',
                  labelKey: 'adminDisputeDecisionBuyer',
                  active: true,
                  sortOrder: 10,
                ),
                AppPolicyOption(
                  policyType: 'dispute_resolution_decision',
                  code: 'seller',
                  labelKey: 'adminDisputeDecisionSeller',
                  active: true,
                  sortOrder: 20,
                ),
              ],
            ),
            disputeOutcomePolicyOptionsProvider.overrideWith(
              (ref) async => const [
                AppPolicyOption(
                  policyType: 'dispute_resolution_outcome_action',
                  code: 'no_action',
                  labelKey: 'adminDisputeOutcomeNoAction',
                  active: true,
                  sortOrder: 10,
                ),
              ],
            ),
            disputeReasonPolicyOptionsProvider.overrideWith(
              (ref) async => const [
                AppPolicyOption(
                  policyType: 'dispute_resolution_reason_code',
                  code: 'fitment_mismatch',
                  labelKey: 'adminDisputeReasonFitmentMismatch',
                  active: true,
                  sortOrder: 10,
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(scope);
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('captures conversation oversight screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'conversation-oversight-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: ConversationOversightScreen(conversationId: 'thread-1'),
            ),
          ),
          overrides: [
            conversationOversightRepositoryProvider.overrideWithValue(
              _FakeConversationOversightRepository(),
            ),
          ],
        );

        await tester.pumpWidget(scope);
        await _pumpUntilFound(
          tester,
          find.byKey(const Key('admin-purpose-select')),
        );
        await tester.tap(find.byKey(const Key('admin-purpose-select')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dispute review').last);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('admin-purpose-confirm')));
        await tester.pumpAndSettle();
      },
    );
  });
}
