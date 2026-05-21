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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({
    super.key,
    this.redirectPath,
    this.redirectArguments,
    this.redirectType = IntentTargetType.route,
    this.variant = SignUpVariant.buyer,
  });

  final String? redirectPath;
  final String? redirectArguments;
  final IntentTargetType redirectType;
  final SignUpVariant variant;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(text: '+213');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: qitakPagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthSurfaceSwitcher(
                onBuyerRole: () => context.go(
                  _buildAuthRoute('/auth/sign-up'),
                ),
                onSellerRole: () => context.go(
                  _buildAuthRoute('/auth/seller/sign-up'),
                ),
                isSellerRole: widget.variant == SignUpVariant.seller,
              ),
              const SizedBox(height: 14),
              QitakPanel(
                child: QitakSectionHeader(
                  eyebrow: context.l10n.authGateEyebrow,
                  title: widget.variant == SignUpVariant.seller
                      ? context.l10n.sellerCreateAccount
                      : context.l10n.createAccount,
                  subtitle: widget.variant == SignUpVariant.seller
                      ? context.l10n.sellerSignUpSubtitle
                      : context.l10n.signUpSubtitle,
                ),
              ),
              const SizedBox(height: 18),
              QitakPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    QitakFormGroup(
                      label: context.l10n.fullNameLabel,
                      child: TextFormField(
                        controller: _fullNameController,
                        validator: (value) =>
                            (value == null || value.trim().length < 2)
                            ? context.l10n.fullNameValidationError
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QitakFormGroup(
                      label: context.l10n.emailLabel,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            (value == null || !value.contains('@'))
                            ? context.l10n.emailValidationError
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QitakFormGroup(
                      label: context.l10n.phoneLabel,
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            (value == null || value.trim().length < 8)
                            ? context.l10n.phoneValidationError
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QitakFormGroup(
                      label: context.l10n.passwordLabel,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? context.l10n.showPassword
                                : context.l10n.hidePassword,
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
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
                    const SizedBox(height: 16),
                    QitakFormGroup(
                      label: context.l10n.confirmPasswordLabel,
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            tooltip: _obscureConfirmPassword
                                ? context.l10n.showPassword
                                : context.l10n.hidePassword,
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (value) => value != _passwordController.text
                            ? context.l10n.confirmPasswordValidationError
                            : null,
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _acceptedTerms,
                      onChanged: (value) =>
                          setState(() => _acceptedTerms = value ?? false),
                      title: Text(context.l10n.acceptTerms),
                    ),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.l10n.createAccount),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  onPressed: () => context.go(
                    _buildAuthRoute(
                      widget.variant == SignUpVariant.seller
                          ? '/auth/seller/sign-in'
                          : '/auth/sign-in',
                    ),
                  ),
                  child: Text(context.l10n.signInPrompt),
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

    if (!_formKey.currentState!.validate() || !_acceptedTerms) {
      if (!_acceptedTerms) {
        _showSnack(context.l10n.termsValidationError);
      }
      return;
    }

    setState(() => _submitting = true);
    final preferences = ref.read(appPreferencesProvider);
    final wasGuestBrowsingEnabled = preferences.guestBrowsingEnabled;
    try {
      final profile = await ref
          .read(authSessionProvider.notifier)
          .signUp(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            variant: widget.variant,
          );
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
      _showSnack(context.l10n.createAccountFailure);
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
    const service = AuthEntryService();
    final isSellerApproved = await _isSellerApproved(profile);
    return service.resolvePostAuthDestination(
      profile: profile,
      intent: intent,
      isSellerApproved: isSellerApproved,
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
}
