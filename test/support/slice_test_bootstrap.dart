import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/admin/data/admin_reports_repository.dart';
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

import 'local_memory_auth_repository.dart';

Future<ProviderScope> buildSliceTestScope(
  Widget child, {
  Map<String, Object> seed = const <String, Object>{},
  List<Object> overrides = const <Object>[],
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
        const AppSupabaseConfig(url: '', anonKey: ''),
      ),
      authRepositoryProvider.overrideWithValue(
        LocalMemoryAuthRepository(prefs),
      ),
      savedListingsRepositoryProvider.overrideWithValue(
        LocalSavedListingsRepository(prefs),
      ),
      messagingRepositoryProvider.overrideWithValue(LocalMessagingRepository()),
      notificationRepositoryProvider.overrideWithValue(
        const LocalNotificationRepository(),
      ),
      adminReportsRepositoryProvider.overrideWithValue(
        const LocalAdminReportsRepository(),
      ),
      listingModerationRepositoryProvider.overrideWithValue(
        LocalListingModerationRepository(prefs),
      ),
      disputeRepositoryProvider.overrideWithValue(
        const LocalDisputeRepository(),
      ),
      transactionRepositoryProvider.overrideWithValue(
        LocalTransactionRepository(),
      ),
      ratingRepositoryProvider.overrideWithValue(LocalRatingRepository()),
      sellerApplicationRepositoryProvider.overrideWith(
        (ref) => LocalSellerApplicationRepository(prefs, ref),
      ),
      ...overrides.cast(),
    ],
    child: child,
  );
}

class SliceTestMaterialShell extends StatelessWidget {
  const SliceTestMaterialShell({required this.child, super.key});

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
