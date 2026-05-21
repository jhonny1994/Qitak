import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/core/notifications/notification_service.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/admin/data/admin_reports_repository.dart';
import 'package:qitak_app/features/admin/data/admin_team_repository.dart';
import 'package:qitak_app/features/admin/data/listing_moderation_repository.dart';
import 'package:qitak_app/features/auth/data/auth_repository.dart';
import 'package:qitak_app/features/listings/data/saved_listings_repository.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';
import 'package:qitak_app/features/notifications/data/notification_repository.dart';
import 'package:qitak_app/features/ratings/data/rating_repository.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/transactions/data/dispute_repository.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderScope> buildTestScope(
  Widget child, {
  Map<String, Object> seed = const <String, Object>{},
  List<Object> overrides = const <Object>[],
  MessagingRepository? messagingRepositoryOverride,
  TransactionRepository? transactionRepositoryOverride,
  SellerApplicationRepository? sellerApplicationRepositoryOverride,
}) async {
  SharedPreferences.setMockInitialValues(seed);
  final prefs = await SharedPreferences.getInstance();
  LocalTransactionRepository.resetForTest();
  LocalRatingRepository.resetForTest();
  LocalMessagingRepository.resetForTest();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appSupabaseConfigProvider.overrideWithValue(
        const AppSupabaseConfig(
          url: 'https://test-project.supabase.co',
          anonKey: 'test-anon-key',
        ),
      ),
      supabaseClientProvider.overrideWithValue(null),
      authRepositoryProvider.overrideWithValue(
        LocalMemoryAuthRepository(prefs),
      ),
      notificationServiceProvider.overrideWithValue(
        const NoopNotificationService(),
      ),
      savedListingsRepositoryProvider.overrideWithValue(
        LocalSavedListingsRepository(prefs),
      ),
      messagingRepositoryProvider.overrideWithValue(
        messagingRepositoryOverride ?? LocalMessagingRepository(),
      ),
      notificationRepositoryProvider.overrideWithValue(
        const LocalNotificationRepository(),
      ),
      adminReportsRepositoryProvider.overrideWithValue(
        const LocalAdminReportsRepository(),
      ),
      adminTeamRepositoryProvider.overrideWithValue(
        const LocalAdminTeamRepository(),
      ),
      listingModerationRepositoryProvider.overrideWithValue(
        LocalListingModerationRepository(prefs),
      ),
      disputeRepositoryProvider.overrideWithValue(
        const LocalDisputeRepository(),
      ),
      transactionRepositoryProvider.overrideWithValue(
        transactionRepositoryOverride ?? LocalTransactionRepository(),
      ),
      ratingRepositoryProvider.overrideWithValue(LocalRatingRepository()),
      sellerApplicationRepositoryProvider.overrideWith(
        (ref) =>
            sellerApplicationRepositoryOverride ??
            LocalSellerApplicationRepository(prefs, ref),
      ),
      ...overrides.cast(),
    ],
    child: child,
  );
}

class TestMaterialShell extends StatelessWidget {
  const TestMaterialShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}

Future<ProviderScope> buildQitakApp({
  Map<String, Object> seed = const <String, Object>{},
}) {
  return buildTestScope(const QitakApp(), seed: seed);
}
