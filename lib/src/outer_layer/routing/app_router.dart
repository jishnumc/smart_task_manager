import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_task_manager/app.dart';
import 'package:smart_task_manager/src/features/auth/auth_screen.dart';

part 'app_router.g.dart';

/// Provides the [GoRouter] instance for application navigation.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const AuthScreen(),
      ),
    ],
  );
}
