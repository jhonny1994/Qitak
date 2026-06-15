import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class AppEntryShell extends StatelessWidget {
  const AppEntryShell({
    required this.child,
    super.key,
    this.fallbackPath,
  });

  final Widget child;
  final String? fallbackPath;

  @override
  Widget build(BuildContext context) {
    final tokens = context.qitakTokens;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: QitakPageCanvas(
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
                child: PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, _) {
                    if (didPop) {
                      return;
                    }
                    if (context.canPop()) {
                      context.pop();
                      return;
                    }
                    final fallback = fallbackPath;
                    if (fallback != null) {
                      context.go(fallback);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
