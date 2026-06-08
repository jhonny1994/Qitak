import 'package:flutter/material.dart';

import 'package:qitak_app/core/l10n/l10n.dart';

class CustomerAuthModeSwitch extends StatelessWidget {
  const CustomerAuthModeSwitch({
    required this.isSellerSelected,
    required this.onSelected,
    super.key,
  });

  final bool isSellerSelected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              key: const Key('customer-auth-mode-buyer'),
              label: context.l10n.profileRoleBuyer,
              selected: !isSellerSelected,
              onPressed: isSellerSelected ? () => onSelected(false) : null,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ModeButton(
              key: const Key('customer-auth-mode-seller'),
              label: context.l10n.profileRoleSeller,
              selected: isSellerSelected,
              onPressed: isSellerSelected ? null : () => onSelected(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        backgroundColor: selected ? colorScheme.primary : Colors.transparent,
        foregroundColor: selected
            ? colorScheme.onPrimary
            : colorScheme.onSurfaceVariant,
        minimumSize: const Size.fromHeight(52),
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
