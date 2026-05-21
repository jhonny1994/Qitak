import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitting = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: qitakPagePadding,
      child: _sent
          ? QitakStateMessage(
              title: context.l10n.checkYourEmail,
              message: context.l10n.passwordResetSuccess,
              icon: Icons.mark_email_read_outlined,
            )
          : ListView(
              children: [
                QitakPanel(
                  child: QitakSectionHeader(
                    eyebrow: context.l10n.authGateEyebrow,
                    title: context.l10n.resetPassword,
                    subtitle: context.l10n.resetPasswordBody,
                  ),
                ),
                const SizedBox(height: 18),
                QitakPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      QitakFormGroup(
                        label: context.l10n.emailLabel,
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(context.l10n.sendResetLink),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref
          .read(authSessionProvider.notifier)
          .requestPasswordReset(_emailController.text.trim());
      if (mounted) {
        setState(() => _sent = true);
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.passwordResetFailure)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
