import 'package:flutter/material.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';

class AuthSurfaceSwitcher extends StatelessWidget {
  const AuthSurfaceSwitcher({
    required this.onBuyerRole,
    required this.onSellerRole,
    required this.isSellerRole,
    super.key,
  });

  final bool isSellerRole;
  final VoidCallback onBuyerRole;
  final VoidCallback onSellerRole;

  @override
  Widget build(BuildContext context) {
    return _SwitchRow(
      leadingLabel: context.l10n.accountRoleLabel(AccountRole.buyer),
      leadingActive: !isSellerRole,
      onLeadingTap: onBuyerRole,
      trailingLabel: context.l10n.accountRoleLabel(AccountRole.seller),
      trailingActive: isSellerRole,
      onTrailingTap: onSellerRole,
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.leadingLabel,
    required this.leadingActive,
    required this.onLeadingTap,
    required this.trailingLabel,
    required this.trailingActive,
    required this.onTrailingTap,
  });

  final String leadingLabel;
  final bool leadingActive;
  final VoidCallback onLeadingTap;
  final String trailingLabel;
  final bool trailingActive;
  final VoidCallback onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SwitchButton(
            label: leadingLabel,
            active: leadingActive,
            onPressed: onLeadingTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SwitchButton(
            label: trailingLabel,
            active: trailingActive,
            onPressed: onTrailingTap,
          ),
        ),
      ],
    );
  }
}

class _SwitchButton extends StatelessWidget {
  const _SwitchButton({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return FilledButton(
        onPressed: null,
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
