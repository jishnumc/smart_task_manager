import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/sync_notifier.dart';

void main() {
  group('SyncNotifierState', () {
    test('initial state has default values', () {
      const state = SyncNotifierState();

      expect(state.unsyncedCount, equals(0));
      expect(state.isPromptVisible, isFalse);
      expect(state.isSyncing, isFalse);
      expect(state.lastResult, isNull);
    });

    test('copyWith updates state fields correctly', () {
      const state = SyncNotifierState();
      final updated = state.copyWith(
        unsyncedCount: 5,
        isPromptVisible: true,
        isSyncing: false,
        lastResult: const SyncResult(syncedCount: 5, failedCount: 0),
      );

      expect(updated.unsyncedCount, equals(5));
      expect(updated.isPromptVisible, isTrue);
      expect(updated.isSyncing, isFalse);
      expect(updated.lastResult?.syncedCount, equals(5));
      expect(updated.lastResult?.failedCount, equals(0));
    });
  });
}
