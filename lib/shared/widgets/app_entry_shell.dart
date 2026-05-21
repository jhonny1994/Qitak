import 'package:flutter/material.dart';

import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class AppEntryShell extends StatelessWidget {
  const AppEntryShell({required this.child, super.key});

  final Widget child;

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
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    tokens.screenPadding,
                    16,
                    tokens.screenPadding,
                    24,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
