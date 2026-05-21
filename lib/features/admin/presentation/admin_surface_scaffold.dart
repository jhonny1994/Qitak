import 'package:flutter/material.dart';

import 'package:qitak_app/shared/widgets/qitak_components.dart';

class AdminSurfaceScaffold extends StatelessWidget {
  const AdminSurfaceScaffold({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: qitakPagePadding,
      children: [
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSectionHeader(
                eyebrow: eyebrow,
                title: title,
                subtitle: subtitle,
              ),
              const SizedBox(height: 18),
              ...children,
            ],
          ),
        ),
      ],
    );
  }
}
