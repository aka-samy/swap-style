import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

// ─── Provider ───────────────────────────────────────────

final _moderationRepoProvider = Provider<_ModerationRepository>((ref) {
  return _ModerationRepository(ref.watch(apiClientProvider));
});

class _ModerationRepository {
  _ModerationRepository(this._client);
  final ApiClient _client;

  Future<void> reportUser(
      String targetUserId, String reason, String? details) async {
    await _client.dio.post(
      '/users/$targetUserId/report',
      data: {'reason': reason, if (details != null) 'details': details},
    );
  }

  Future<void> reportItem(
      String targetItemId, String reason, String? details) async {
    await _client.dio.post(
      '/items/$targetItemId/report',
      data: {'reason': reason, if (details != null) 'details': details},
    );
  }

  Future<void> blockUser(String targetUserId) async {
    await _client.dio.post('/users/$targetUserId/block');
  }

  Future<void> unblockUser(String targetUserId) async {
    await _client.dio.delete('/users/$targetUserId/block');
  }
}

// ─── Report Dialog ──────────────────────────────────────

enum _ReportTarget { user, item }

Future<void> showReportDialog(
  BuildContext context, {
  required WidgetRef ref,
  String? targetUserId,
  String? targetItemId,
}) async {
  assert(
    targetUserId != null || targetItemId != null,
    'Must provide either targetUserId or targetItemId',
  );

  final target =
      targetUserId != null ? _ReportTarget.user : _ReportTarget.item;
  final targetId = (targetUserId ?? targetItemId)!;

  final reasonController = TextEditingController();
  final detailsController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        target == _ReportTarget.user ? 'Report User' : 'Report Item',
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason *',
                hintText: 'e.g. Spam, Inappropriate content',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
              maxLength: 120,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: detailsController,
              decoration: const InputDecoration(
                labelText: 'Details (optional)',
              ),
              maxLines: 3,
              maxLength: 1000,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;

            final repo = ref.read(_moderationRepoProvider);
            final reason = reasonController.text.trim();
            final details = detailsController.text.trim();

            try {
              if (target == _ReportTarget.user) {
                await repo.reportUser(
                  targetId,
                  reason,
                  details.isEmpty ? null : details,
                );
              } else {
                await repo.reportItem(
                  targetId,
                  reason,
                  details.isEmpty ? null : details,
                );
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted. Thank you.'),
                  ),
                );
              }
            } catch (_) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Failed to submit report.')),
                );
              }
            }
          },
          child: const Text('Submit'),
        ),
      ],
    ),
  );
}

// ─── Block / Unblock ────────────────────────────────────

Future<void> showBlockConfirmation(
  BuildContext context, {
  required WidgetRef ref,
  required String targetUserId,
  required String displayName,
  required bool isCurrentlyBlocked,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(isCurrentlyBlocked ? 'Unblock User' : 'Block User'),
      content: Text(
        isCurrentlyBlocked
            ? 'Unblock $displayName? They will be able to see you again.'
            : 'Block $displayName? They won\'t be able to match or chat with you.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: isCurrentlyBlocked
              ? null
              : FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                ),
          child: Text(isCurrentlyBlocked ? 'Unblock' : 'Block'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    final repo = ref.read(_moderationRepoProvider);
    try {
      if (isCurrentlyBlocked) {
        await repo.unblockUser(targetUserId);
      } else {
        await repo.blockUser(targetUserId);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyBlocked ? '$displayName unblocked.' : '$displayName blocked.',
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action failed. Please try again.')),
        );
      }
    }
  }
}

// ─── Convenience PopupMenu items ────────────────────────

List<PopupMenuEntry<String>> buildModerationMenuItems({
  required bool isBlocked,
}) {
  return [
    PopupMenuItem(
      value: 'report',
      child: const ListTile(
        leading: Icon(Icons.flag_outlined),
        title: Text('Report'),
        contentPadding: EdgeInsets.zero,
      ),
    ),
    PopupMenuItem(
      value: isBlocked ? 'unblock' : 'block',
      child: ListTile(
        leading: Icon(isBlocked ? Icons.lock_open_outlined : Icons.block),
        title: Text(isBlocked ? 'Unblock' : 'Block'),
        contentPadding: EdgeInsets.zero,
      ),
    ),
  ];
}
