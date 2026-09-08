import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_state.dart';
import 'package:smart_task_manager/src/features/auth/presentation/view/auth_screen.dart';
import 'package:smart_task_manager/src/features/dashboard/presentation/view/dashboard_screen.dart';

import 'package:smart_task_manager/src/features/splash/presentation/view/splash_screen.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/view/create_task_screen.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/view/task_detail_screen.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/view/task_list_screen.dart';

part 'app_router.g.dart';

/// Listenable wrapper around Riverpod AuthNotifier for GoRouter refreshListenable.
class RouterAuthRefreshNotifier extends ChangeNotifier {
  RouterAuthRefreshNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, _) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

/// Provides the [GoRouter] instance for application navigation.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = RouterAuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      if (state.matchedLocation == '/splash') {
        return null; // Stay on splash route until animation completes
      }

      if (authState is AuthInitial || authState is AuthLoading) {
        return null; // Stay on current route while loading initial auth state
      }

      final isLoggingIn = state.matchedLocation == '/auth';

      if (authState is Unauthenticated || authState is AuthError) {
        return isLoggingIn ? null : '/auth';
      }

      if (authState is Authenticated) {
        return isLoggingIn ? '/dashboard' : null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/create-task',
        name: 'create-task',
        builder: (context, state) => const CreateTaskScreen(),
      ),
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/task-detail',
        name: 'task-detail',
        builder: (context, state) {
          final task = state.extra as TaskEntity;
          return TaskDetailScreen(task: task);
        },
      ),
    ],
  );
}
