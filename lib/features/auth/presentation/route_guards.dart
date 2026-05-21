import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/auth_entry_service.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';
import 'package:qitak_app/features/auth/presentation/guest_account_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/auth/providers/redirect_intent_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';

class ProtectedRouteGuard extends ConsumerWidget {
  const ProtectedRouteGuard({
    required this.requiredRoles,
    required this.intent,
    required this.child,
    this.requireApprovedSeller = false,
    super.key,
  });

  final List<AccountRole> requiredRoles;
  final PostAuthRedirectIntent intent;
  final Widget child;
  final bool requireApprovedSeller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final rememberedIntent = ref.watch(redirectIntentProvider);
    const service = AuthEntryService();

    if (!session.isAuthenticated) {
      if (rememberedIntent != intent) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          ref.read(redirectIntentProvider.notifier).rememberedIntent = intent;
        });
      }
      return GuestAccountScreen(
        redirectPath: intent.targetValue,
        redirectArguments: intent.toQueryParameters()['intentArgs'],
        redirectType: intent.targetType,
      );
    }

    final profile = session.profile!;
    final sellerApplication = profile.role == AccountRole.seller
        ? ref.watch(currentSellerApplicationProvider)
        : const AsyncData<SellerApplication?>(null);
    if (profile.role == AccountRole.seller && requireApprovedSeller) {
      if (sellerApplication.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (sellerApplication.asData?.value?.isApproved != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/seller/onboarding/status');
          }
        });
        return const SizedBox.shrink();
      }
    }

    final isSellerApproved =
        sellerApplication.asData?.value?.isApproved ?? false;
    if (!requiredRoles.contains(profile.role) ||
        !service.canAccessRoleRoute(
          profile.role,
          intent.targetValue,
          isSellerApproved: isSellerApproved,
        )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(
            service.resolveLandingRoute(
              profile,
              isSellerApproved: isSellerApproved,
            ),
          );
        }
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}
