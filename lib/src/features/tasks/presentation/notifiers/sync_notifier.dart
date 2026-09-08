import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/create_task_notifier.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/task_list_notifier.dart';
import 'package:smart_task_manager/src/outer_layer/network/network_info.dart';

part 'sync_notifier.g.dart';

class SyncNotifierState {
  const SyncNotifierState({
    this.unsyncedCount = 0,
    this.isPromptVisible = false,
    this.isSyncing = false,
    this.lastResult,
  });

  final int unsyncedCount;
  final bool isPromptVisible;
  final bool isSyncing;
  final SyncResult? lastResult;

  SyncNotifierState copyWith({
    int? unsyncedCount,
    bool? isPromptVisible,
    bool? isSyncing,
    SyncResult? lastResult,
  }) {
    return SyncNotifierState(
      unsyncedCount: unsyncedCount ?? this.unsyncedCount,
      isPromptVisible: isPromptVisible ?? this.isPromptVisible,
      isSyncing: isSyncing ?? this.isSyncing,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}

@Riverpod(keepAlive: true)
class SyncNotifier extends _$SyncNotifier {
  StreamSubscription<bool>? _networkSubscription;

  @override
  SyncNotifierState build() {
    final networkInfo = ref.watch(networkInfoProvider);
    _networkSubscription?.cancel();
    _networkSubscription =
        networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        checkAndPromptSync();
      }
    });

    ref.onDispose(() {
      _networkSubscription?.cancel();
    });

    Future.microtask(() => checkAndPromptSync());

    return const SyncNotifierState();
  }

  Future<void> checkAndPromptSync() async {
    try {
      final networkInfo = ref.read(networkInfoProvider);
      final isConnected = await networkInfo.isConnected;

      final repository = ref.read(taskRepositoryProvider);
      final unsynced = await repository.getUnsyncedTasks();

      if (isConnected && unsynced.isNotEmpty) {
        state = state.copyWith(
          unsyncedCount: unsynced.length,
          isPromptVisible: true,
        );
      } else {
        state = state.copyWith(
          unsyncedCount: unsynced.length,
          isPromptVisible: false,
        );
      }
    } catch (_) {}
  }

  void dismissPrompt() {
    state = state.copyWith(isPromptVisible: false);
  }

  Future<SyncResult> performSync() async {
    state = state.copyWith(isSyncing: true, isPromptVisible: false);

    try {
      final repository = ref.read(taskRepositoryProvider);
      final result = await repository.syncOfflineTasks();

      await ref.read(taskListProvider.notifier).refreshTasks();

      final remaining = await repository.getUnsyncedTasks();

      state = state.copyWith(
        isSyncing: false,
        unsyncedCount: remaining.length,
        isPromptVisible: remaining.isNotEmpty,
        lastResult: result,
      );

      return result;
    } catch (e) {
      state = state.copyWith(isSyncing: false);
      return const SyncResult(syncedCount: 0, failedCount: 1);
    }
  }
}

final syncNotifierProvider = syncProvider;

