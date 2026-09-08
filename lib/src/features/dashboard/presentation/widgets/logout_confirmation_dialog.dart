import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/sync_notifier.dart';
import 'package:smart_task_manager/src/outer_layer/network/network_info.dart';

class LogoutConfirmationDialog extends ConsumerStatefulWidget {
  const LogoutConfirmationDialog({
    super.key,
    required this.onConfirm,
  });

  final VoidCallback onConfirm;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => LogoutConfirmationDialog(onConfirm: onConfirm),
    );
  }

  @override
  ConsumerState<LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState
    extends ConsumerState<LogoutConfirmationDialog> {
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(syncNotifierProvider.notifier).checkAndPromptSync();
    });
  }

  Future<void> _handleSyncAndSignOut() async {
    final isConnected = await ref.read(networkInfoProvider).isConnected;
    if (!isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Unable to sync tasks right now.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    final result =
        await ref.read(syncNotifierProvider.notifier).performSync();

    if (mounted) {
      setState(() {
        _isSyncing = false;
      });

      if (result.syncedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully synced ${result.syncedCount} task(s).'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      Navigator.of(context).pop();
      widget.onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final syncState = ref.watch(syncNotifierProvider);
    final hasUnsynced = syncState.unsyncedCount > 0;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: (hasUnsynced ? Colors.orange : colors.error)
                  .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasUnsynced ? Icons.cloud_off_rounded : Icons.logout_rounded,
              color: hasUnsynced ? Colors.orange : colors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              hasUnsynced ? 'Unsynced Tasks Found' : 'Sign Out',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.mainText,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            if (hasUnsynced) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'You have ${syncState.unsyncedCount} unsynced task(s) saved locally. If you sign out now, these tasks will remain saved locally on this device.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.mainText,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              hasUnsynced
                  ? 'Would you like to sync your tasks before signing out?'
                  : 'Are you sure you want to sign out of Smart Task Manager?',
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.subText,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_isSyncing)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.subText)),
          ),
          if (hasUnsynced) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onConfirm();
              },
              child: Text(
                'Sign Out Anyway',
                style: TextStyle(color: colors.error),
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
              onPressed: _handleSyncAndSignOut,
              icon: const Icon(Icons.cloud_upload_rounded, size: 18),
              label: const Text('Sync & Sign Out'),
            ),
          ] else ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onConfirm();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ],
      ],
    );
  }
}

