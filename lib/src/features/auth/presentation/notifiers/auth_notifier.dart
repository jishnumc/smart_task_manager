import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_task_manager/src/design_system/theme/theme_mode_provider.dart';
import 'package:smart_task_manager/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:smart_task_manager/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_task_manager/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_task_manager/src/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:smart_task_manager/src/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:smart_task_manager/src/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:smart_task_manager/src/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:smart_task_manager/src/features/auth/domain/usecases/update_user_profile_usecase.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_state.dart';
import 'package:smart_task_manager/src/system/exceptions/app_exception.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(AuthRemoteDataSourceImpl());
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _checkInitialAuthState();
    return const AuthInitial();
  }

  Future<void> _checkInitialAuthState() async {
    state = const AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await GetCurrentUserUseCase(repository)();
      if (user != null) {
        state = Authenticated(user);
        ref.read(themeModeProvider.notifier).setThemeMode(user.themeMode);
      } else {
        state = const Unauthenticated();
      }
    } catch (e) {
      state = const Unauthenticated();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await SignInUseCase(repository)(
        email: email,
        password: password,
      );
      state = Authenticated(user);
      ref.read(themeModeProvider.notifier).setThemeMode(user.themeMode);
    } on AppException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await SignUpUseCase(repository)(
        email: email,
        password: password,
        name: name,
      );
      state = Authenticated(user);
      ref.read(themeModeProvider.notifier).setThemeMode(user.themeMode);
    } on AppException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await SignOutUseCase(repository)();
      state = const Unauthenticated();
    } on AppException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> updateProfile({
    required String name,
    ThemeMode? themeMode,
  }) async {
    final currentState = state;
    if (currentState is! Authenticated) return;

    final themeModeStr = themeMode != null
        ? _themeModeToString(themeMode)
        : null;

    try {
      final repository = ref.read(authRepositoryProvider);
      final updatedUser = await UpdateUserProfileUseCase(repository)(
        name: name,
        themeMode: themeModeStr,
      );
      state = Authenticated(updatedUser);

      if (themeMode != null) {
        ref.read(themeModeProvider.notifier).setThemeMode(themeMode);
      }
    } on AppException catch (e) {
      state = AuthError(e.message);
      // Revert back to authenticated state after error broadcast
      state = Authenticated(currentState.user);
    } catch (e) {
      state = AuthError(e.toString());
      state = Authenticated(currentState.user);
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
