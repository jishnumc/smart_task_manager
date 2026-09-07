import 'package:smart_task_manager/src/features/auth/domain/entities/user_entity.dart';

/// Contract for Authentication repository operations.
abstract class AuthRepository {
  /// Stream of authentication state changes.
  Stream<UserEntity?> authStateChanges();

  /// Gets current authenticated user details from Firestore.
  Future<UserEntity?> getCurrentUser();

  /// Sign in with email and password.
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register new user with email, password, and name.
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  /// Sign out current user.
  Future<void> signOut();

  /// Update user profile details in Firestore.
  Future<UserEntity> updateUserProfile({
    required String name,
    String? themeMode,
  });
}
