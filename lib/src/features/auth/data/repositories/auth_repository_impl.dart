import 'package:smart_task_manager/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:smart_task_manager/src/features/auth/domain/entities/user_entity.dart';
import 'package:smart_task_manager/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<UserEntity?> authStateChanges() {
    return _remoteDataSource.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      return _remoteDataSource.getCurrentUser();
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) {
    return _remoteDataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  Future<UserEntity> updateUserProfile({
    required String name,
    String? themeMode,
  }) {
    return _remoteDataSource.updateUserProfile(
      name: name,
      themeMode: themeMode,
    );
  }
}
