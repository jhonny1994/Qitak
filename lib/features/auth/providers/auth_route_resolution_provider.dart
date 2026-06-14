import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/auth_entry_service.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';

Future<bool> resolveSellerApprovalStatus(
  SellerApplicationRepository sellerApplications,
  AccountProfile profile,
) async {
  if (profile.role != AccountRole.seller) {
    return false;
  }
  try {
    final application = await sellerApplications.fetchCurrentForUser(
      profile.id,
    );
    return application?.isApproved ?? false;
  } on Object {
    return false;
  }
}

Future<String> resolveLandingRouteForProfile(
  SellerApplicationRepository sellerApplications,
  AccountProfile profile,
) async {
  final isSellerApproved = await resolveSellerApprovalStatus(
    sellerApplications,
    profile,
  );
  return const AuthEntryService().resolveLandingRoute(
    profile,
    isSellerApproved: isSellerApproved,
  );
}

Future<String> resolvePostAuthRouteForProfile(
  SellerApplicationRepository sellerApplications, {
  required AccountProfile profile,
  PostAuthRedirectIntent? intent,
}) async {
  final isSellerApproved = await resolveSellerApprovalStatus(
    sellerApplications,
    profile,
  );
  return const AuthEntryService().resolvePostAuthDestination(
    profile: profile,
    intent: intent,
    isSellerApproved: isSellerApproved,
  );
}
