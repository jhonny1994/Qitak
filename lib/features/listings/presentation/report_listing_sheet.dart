import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/listings/data/listing_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

Future<void> showReportListingSheet(
  BuildContext context, {
  required String listingId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => ReportListingSheet(listingId: listingId),
  );
}

class ReportListingSheet extends ConsumerStatefulWidget {
  const ReportListingSheet({
    required this.listingId,
    super.key,
  });

  final String listingId;

  @override
  ConsumerState<ReportListingSheet> createState() => _ReportListingSheetState();
}

class _ReportListingSheetState extends ConsumerState<ReportListingSheet> {
  String? _selectedReason;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.68,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: QitakPanel(
          child: ListView(
            controller: scrollController,
            children: [
              QitakSectionHeader(
                eyebrow: context.l10n.reportListingAction,
                title: context.l10n.reportListingAction,
                subtitle: context.l10n.reportListingAlreadyReported,
              ),
              const SizedBox(height: 16),
              RadioGroup<String>(
                groupValue: _selectedReason,
                onChanged: _submitting ? _ignoreReasonChange : _selectReason,
                child: Column(
                  children: [
                    _ReasonTile(
                      title: context.l10n.reportListingReasonSpam,
                      value: 'spam',
                    ),
                    _ReasonTile(
                      title: context.l10n.reportListingReasonMisleading,
                      value: 'misleading',
                    ),
                    _ReasonTile(
                      title: context.l10n.reportListingReasonWrongCategory,
                      value: 'wrong_category',
                    ),
                    _ReasonTile(
                      title: context.l10n.reportListingReasonOther,
                      value: 'other',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _submitting || _selectedReason == null
                    ? null
                    : _submit,
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.reportListingAction),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(context.l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectReason(String? value) {
    setState(() => _selectedReason = value);
  }

  void _ignoreReasonChange(String? _) {}

  Future<void> _submit() async {
    final selectedReason = _selectedReason;
    if (selectedReason == null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(listingRepositoryProvider)
          .reportListing(widget.listingId, selectedReason);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.reportListingSuccess)),
      );
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      setState(() => _submitting = false);
    }
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      contentPadding: EdgeInsets.zero,
    );
  }
}
