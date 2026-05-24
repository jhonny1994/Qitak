import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _initialized = false;
  bool _submitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authSessionProvider).profile;
    if (profile == null) {
      return Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.authGateTitle,
          message: context.l10n.authGateBody,
        ),
      );
    }

    if (!_initialized) {
      _fullNameController.text = profile.fullName;
      _phoneController.text = profile.phone;
      _initialized = true;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        padding: qitakPagePadding,
        children: [
          QitakPanel(
            child: QitakSectionHeader(
              eyebrow: context.l10n.accountSettingsEyebrow,
              title: context.l10n.accountSettingsTitle,
              subtitle: context.l10n.accountSettingsSubtitle,
            ),
          ),
          const SizedBox(height: 18),
          QitakPanel(
            child: Form(
              key: _formKey,
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
                    label: context.l10n.phoneLabel,
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          (value == null ||
                              !RegExp(
                                r'^(0[567]\d{8}|\+213[567]\d{8})$',
                              ).hasMatch(value.trim()))
                          ? context.l10n.phoneValidationError
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QitakFormGroup(
                    label: context.l10n.emailLabel,
                    helper: context.l10n.accountSettingsEmailLocked,
                    child: TextFormField(
                      initialValue: profile.email,
                      enabled: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('account-settings-save'),
                    onPressed: _submitting ? null : _save,
                    child: _submitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.accountSettingsSave),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    key: const Key('account-settings-password-reset'),
                    onPressed: _submitting ? null : _openPasswordDialog,
                    child: Text(
                      context.l10n.accountSettingsChangePasswordAction,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          QitakPanel(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_rounded),
              title: Text(context.l10n.transactionHistoryTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/transactions/history'),
            ),
          ),
          const SizedBox(height: 18),
          QitakPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.accountSettingsDeleteAccountTitle,
                  style:
                      Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(context.l10n.accountSettingsDeleteAccountBody),
                const SizedBox(height: 16),
                OutlinedButton(
                  key: const Key('account-settings-delete-account'),
                  onPressed: _submitting ? null : _confirmDeleteAccount,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(context.l10n.accountSettingsDeleteAccountAction),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(authSessionProvider.notifier)
          .updateProfile(
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.accountSettingsSaved)),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _openPasswordDialog() async {
    FocusScope.of(context).unfocus();
    _passwordController.clear();
    _confirmPasswordController.clear();
    final changed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.accountSettingsUpdatePasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.l10n.accountSettingsNewPasswordLabel,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.l10n.accountSettingsConfirmPasswordLabel,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.riskCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.accountSettingsUpdatePasswordConfirm),
          ),
        ],
      ),
    );
    if (changed != true) {
      return;
    }
    if (!mounted) {
      return;
    }

    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    if (newPassword.length < 8) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.accountSettingsPasswordTooShort)),
      );
      return;
    }
    if (newPassword != confirmPassword) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.accountSettingsPasswordMismatch)),
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _submitting = true);
    try {
      await ref.read(authSessionProvider.notifier).updatePassword(newPassword);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.accountSettingsPasswordUpdated)),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.accountSettingsDeleteAccountTitle),
        content: Text(context.l10n.accountSettingsDeleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.riskCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.accountSettingsDeleteAccountConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final successMessage = context.l10n.accountSettingsDeleteAccountSuccess;
    setState(() => _submitting = true);
    try {
      await ref.read(authSessionProvider.notifier).deactivateAccount();
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
        ),
      );
      router.go('/guest/account');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
