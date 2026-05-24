import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/auth_entry_service.dart';
import 'package:qitak_app/features/auth/domain/auth_variant.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';
import 'package:qitak_app/features/auth/presentation/app_preferences_controller.dart';
import 'package:qitak_app/features/auth/presentation/auth_surface_switcher.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/auth/providers/redirect_intent_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({
    super.key,
    this.redirectPath,
    this.redirectArguments,
    this.redirectType = IntentTargetType.route,
    this.variant = SignInVariant.buyer,
  });

  final String? redirectPath;
  final String? redirectArguments;
  final IntentTargetType redirectType;
  final SignInVariant variant;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);

    if (session.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && session.profile != null) {
          final profile = session.profile!;
          if (_isAllowedRole(profile.role)) {
            unawaited(_goToLanding(profile));
          }
        }
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      excludeFromSemantics: true,
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: qitakPagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.variant != SignInVariant.admin) ...[
                AuthSurfaceSwitcher(
                  onBuyerRole: () =>
                      context.go(_buildAuthRoute('/auth/sign-in')),
                  onSellerRole: () =>
                      context.go(_buildAuthRoute('/auth/seller/sign-in')),
                  isSellerRole: widget.variant == SignInVariant.seller,
                ),
                const SizedBox(height: 14),
              ],
              QitakPanel(
                child: QitakSectionHeader(
                  eyebrow: context.l10n.authGateEyebrow,
                  title: context.l10n.welcomeBack,
                  subtitle: _subtitle(context),
                ),
              ),
              const SizedBox(height: 14),
              QitakPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    QitakFormGroup(
                      label: context.l10n.emailLabel,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            (value == null ||
                                !RegExp(
                                  r'^[\w.%+\-]+@[\w.\-]+\.[a-zA-Z]{2,}$',
                                ).hasMatch(value.trim()))
                            ? context.l10n.emailValidationError
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QitakFormGroup(
                      label: context.l10n.passwordLabel,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            tooltip: _obscureText
                                ? context.l10n.showPassword
                                : context.l10n.hidePassword,
                            onPressed: () =>
                                setState(() => _obscureText = !_obscureText),
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            (value == null || value.length < 8)
                            ? context.l10n.passwordValidationError
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.padded,
                          ),
                          onPressed: () => context.go('/auth/reset-password'),
                          child: Text(context.l10n.forgotPassword),
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.l10n.signIn),
                    ),
                    const SizedBox(height: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.l10n.googleComingSoon,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (widget.variant != SignInVariant.admin)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    onPressed: () => context.go(
                      _buildAuthRoute(
                        widget.variant == SignInVariant.seller
                            ? '/auth/seller/sign-up'
                            : '/auth/sign-up',
                      ),
                    ),
                    child: Text(
                      widget.variant == SignInVariant.seller
                          ? context.l10n.sellerCreateAccountPrompt
                          : context.l10n.createAccountPrompt,
                    ),
                  ),
                ),
              if (widget.variant == SignInVariant.admin)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    onPressed: () {
                      ref
                              .read(redirectIntentProvider.notifier)
                              .rememberedIntent =
                          null;
                      context.go('/guest/account');
                    },
                    child: Text(context.l10n.backToUserAuth),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    final preferences = ref.read(appPreferencesProvider);
    final wasGuestBrowsingEnabled = preferences.guestBrowsingEnabled;

    try {
      final profile = await ref
          .read(authSessionProvider.notifier)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      _passwordController.clear();
      if (!_isAllowedRole(profile.role)) {
        await ref.read(authSessionProvider.notifier).signOut();
        if (!mounted) return;
        _showSnack(_accessDeniedMessage(context));
        return;
      }

      if (wasGuestBrowsingEnabled) {
        await ref
            .read(appPreferencesProvider.notifier)
            .setGuestBrowsingEnabled(enabled: false);
      }

      final route = await _resolvePostAuthRoute(profile);
      if (mounted) {
        context.go(route);
      }
    } on AppException catch (error) {
      if (!mounted) return;
      _showSnack(error.message);
    } on Object {
      if (!mounted) return;
      _showSnack(context.l10n.invalidCredentialsGeneric);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _goToLanding(AccountProfile profile) async {
    final route = await _resolveLandingRoute(profile);
    if (mounted) {
      context.go(route);
    }
  }

  Future<bool> _isSellerApproved(AccountProfile profile) async {
    if (profile.role != AccountRole.seller) {
      return false;
    }
    try {
      final application = await ref
          .read(sellerApplicationRepositoryProvider)
          .fetchCurrentForUser(profile.id);
      return application?.isApproved ?? false;
    } on Object {
      return false;
    }
  }

  Future<String> _resolvePostAuthRoute(AccountProfile profile) async {
    final intent =
        ref.read(redirectIntentProvider.notifier).consume() ??
        PostAuthRedirectIntent.fromQueryParameters(
          redirectPath: widget.redirectPath,
          redirectType: widget.redirectType,
          encodedArguments: widget.redirectArguments,
        );
    final isSellerApproved = await _isSellerApproved(profile);
    return const AuthEntryService().resolvePostAuthDestination(
      profile: profile,
      intent: intent,
      isSellerApproved: isSellerApproved,
    );
  }

  Future<String> _resolveLandingRoute(AccountProfile profile) async {
    return const AuthEntryService().resolveLandingRoute(
      profile,
      isSellerApproved: await _isSellerApproved(profile),
    );
  }

  String _buildAuthRoute(String basePath) {
    final intent = PostAuthRedirectIntent.fromQueryParameters(
      redirectPath: widget.redirectPath,
      redirectType: widget.redirectType,
      encodedArguments: widget.redirectArguments,
    );
    if (intent == null) {
      return basePath;
    }
    return '$basePath?${Uri(queryParameters: intent.toQueryParameters()).query}';
  }

  bool _isAllowedRole(AccountRole role) {
    switch (widget.variant) {
      case SignInVariant.buyer:
        return role == AccountRole.buyer;
      case SignInVariant.seller:
        return role == AccountRole.seller;
      case SignInVariant.admin:
        return role == AccountRole.admin || role == AccountRole.superAdmin;
    }
  }

  String _accessDeniedMessage(BuildContext context) {
    switch (widget.variant) {
      case SignInVariant.buyer:
        return context.l10n.buyerAccessDenied;
      case SignInVariant.seller:
        return context.l10n.sellerAccessDenied;
      case SignInVariant.admin:
        return context.l10n.adminAccessDenied;
    }
  }

  String _subtitle(BuildContext context) {
    switch (widget.variant) {
      case SignInVariant.buyer:
        return context.l10n.signInSubtitle;
      case SignInVariant.seller:
        return context.l10n.sellerSignInSubtitle;
      case SignInVariant.admin:
        return context.l10n.adminSignInSubtitle;
    }
  }
}
