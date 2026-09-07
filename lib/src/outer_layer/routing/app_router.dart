import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_state.dart';
import 'package:smart_task_manager/src/features/auth/presentation/view/auth_screen.dart';
import 'package:smart_task_manager/src/features/dashboard/presentation/view/dashboard_screen.dart';

import 'package:smart_task_manager/src/features/tasks/presentation/view/create_task_screen.dart';
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
    initialLocation: '/auth',
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authProvider);

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
    ],
  );
}
