import 'package:flutter/material.dart';

import 'package:qitak_app/core/l10n/l10n.dart';

Future<String?> promptTransactionActionNote(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String? initialValue,
}) {
  final formKey = GlobalKey<FormState>();
  var note = initialValue ?? '';
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(body),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: initialValue,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: context.l10n.transactionReasonLabel,
                  hintText: context.l10n.transactionReasonHint,
                ),
                onChanged: (value) => note = value,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return context.l10n.transactionReasonRequired;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(dialogContext).pop(note.trim());
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
