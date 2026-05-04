import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';
import '../providers/profile_provider.dart';

class ReportUserSheet extends ConsumerStatefulWidget {
  final String targetUserId;

  const ReportUserSheet({super.key, required this.targetUserId});

  @override
  ConsumerState<ReportUserSheet> createState() => _ReportUserSheetState();
}

class _ReportUserSheetState extends ConsumerState<ReportUserSheet> {
  String _selectedReason = 'Inappropriate behavior';
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Inappropriate behavior',
    'Scam or Fraud',
    'Offensive language',
    'Spam',
    'Other'
  ];

  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(profileRepositoryProvider).reportUser(
            widget.targetUserId,
            _selectedReason,
            _commentController.text,
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit report')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Report User',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedReason,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
            ),
            items: _reasons.map((reason) {
              return DropdownMenuItem(value: reason, child: Text(reason));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedReason = val);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Additional Details (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _submitReport,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Submit Report'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
