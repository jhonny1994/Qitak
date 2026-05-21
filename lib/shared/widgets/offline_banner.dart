import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/connectivity/connectivity_service.dart';
import 'package:qitak_app/core/l10n/l10n.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).asData?.value ?? true;

    return Stack(
      children: [
        child,
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: isOnline ? 0 : 36,
              width: double.infinity,
              color: Theme.of(context).colorScheme.error,
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: isOnline
                  ? const SizedBox.shrink()
                  : Text(
                      context.l10n.offlineBannerLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onError,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
