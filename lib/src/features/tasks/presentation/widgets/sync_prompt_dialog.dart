import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/sync_notifier.dart';

class SyncPromptDialog extends ConsumerWidget {
  const SyncPromptDialog({
    super.key,
    required this.unsyncedCount,
  });

  final int unsyncedCount;

  static bool _isShowing = false;

  static Future<void> show(
    BuildContext context, {
    required int unsyncedCount,
  }) async {
    if (_isShowing) return;
    _isShowing = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SyncPromptDialog(unsyncedCount: unsyncedCount),
    );
    _isShowing = false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final syncState = ref.watch(syncNotifierProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_upload_rounded,
              color: colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Unsynced Tasks',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.mainText,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have $unsyncedCount task(s) saved locally while offline. Would you like to sync them with the server now?',
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.subText,
            ),
          ),
          if (syncState.isSyncing) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Syncing tasks to remote server...',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: syncState.isSyncing
          ? []
          : [
              TextButton(
                onPressed: () {
                  ref.read(syncNotifierProvider.notifier).dismissPrompt();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Not Now',
                  style: TextStyle(color: colors.subText),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.sync_rounded, size: 18),
                label: const Text('Sync Now'),
                onPressed: () async {
                  final result = await ref
                      .read(syncNotifierProvider.notifier)
                      .performSync();

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    final message = result.failedCount == 0
                        ? 'Successfully synced ${result.syncedCount} task(s) to server!'
                        : 'Synced ${result.syncedCount} task(s), ${result.failedCount} failed.';

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: result.failedCount == 0
                            ? colors.primary
                            : Colors.orange.shade700,
                      ),
                    );
                  }
                },
              ),
            ],
    );
  }
}
