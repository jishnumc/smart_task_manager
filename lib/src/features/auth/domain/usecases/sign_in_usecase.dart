import 'package:smart_task_manager/src/features/auth/domain/entities/user_entity.dart';
import 'package:smart_task_manager/src/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  const SignInUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<UserEntity> call({
    required String email,
    required String password,
  }) {
    return _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
